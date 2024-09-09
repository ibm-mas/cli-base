# -----------------------------------------------------------
# Licensed Materials - Property of IBM
# 5737-M66, 5900-AAA
# (C) Copyright IBM Corp. 2024 All Rights Reserved.
# US Government Users Restricted Rights - Use, duplication, or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
# -----------------------------------------------------------

import argparse
import json
import os
import re
from html.parser import HTMLParser

parser = argparse.ArgumentParser()
parser.add_argument(
    "--req-file", type=str, required=True, help="Path of the requirements.txt file"
)
parser.add_argument(
    "--dest",
    type=str,
    required=True,
    help="Target location to save the downloaded wheels of the requirements.txt file",
)
parser.add_argument(
    "--arch", type=str, required=False, help="Architecture of the target platform"
)
parser.add_argument(
    "--add-dependency", type=str, required=True, help="Additional dependencies that are image specific. Use ',' for multiple dependencies"
)
args = parser.parse_args()

requirementPath, destination, arch, add_dependency = args.req_file, args.dest, args.arch, args.add_dependency

ARTIFACTORY_URL = "https://na.artifactory.swg-devops.com/artifactory/wiotp-generic-local/dependencies/wheels/s390x"
W3_USERNAME, ARTIFACTORY_TOKEN = os.environ["W3_USERNAME"], os.environ["ARTIFACTORY_TOKEN"]

# prebuiltpackages: List of packages that are required to download from artifactory. Contains only the package name (Can specify default packages, if required).
prebuiltpackages = []

#requirements_dict: Dictionary of packages in requirements.txt file given as argument in the format {package_name: version}.
# artifactory_wheels: List of all the packages that are already uploaded to artifactory.
requirements_dict, artifactory_wheels = {}, []

# The additional dependencies are added to prebuiltpackages list
if add_dependency != None:
    new_dependency = add_dependency.split(",")
    for pkg in new_dependency:
        prebuiltpackages.append(pkg)

# Initialize the dictionary with None for all prebuilt packages
prebuiltpackages = {pkg_name: None for pkg_name in prebuiltpackages}

# ************************************************************************************************************#

# We could use some HTML parser, but it would add the overhead of installing on travis, so modified python's in-built HTML parser according to requirement.
class MyHTMLParser(HTMLParser):
    """
    A custom HTML parser for extracting links from an HTML document.
    Attributes:
      recording (bool): A flag indicating whether we're currently recording a link.
      data (list): A list of strings representing the extracted links.
    """

    def __init__(self):
        """
        Initializes the MyHTMLParser object.
        """
        super().__init__()
        self.recording = False
        self.data = []

    def handle_starttag(self, tag, attrs):
        """
        Handles the start of a new HTML tag. Here we are checking if the current tag is an <a> tag. If it is, we set the recording flag to True.
        Args:
          tag (str): The name of the tag.
          attrs (list): A list of attributes associated with the tag.
        """
        if tag == "a":
            self.recording = True

    def handle_endtag(self, tag):
        """
        Handles the end of an HTML tag. Here we are checking if the closing tag is an <a> tag. If it is, we set the recording flag to False.
        Args:
          tag (str): The name of the tag.
        """
        if tag == "a":
            self.recording = False

    def handle_data(self, data):
        """
        Handles the data inside an HTML tag. Here we are appending the data to the data list if the recording flag is True.
        Args:
          data (str): The data inside the tag.
        """
        if self.recording:
            self.data.append(data)


def parserequirementsFile(requirementPath: str) -> dict:
    """
    This function parses the requirements file and returns a dictionary of requirements with key as package name and value as its corresponding version.
    Parameters:
      requirementPath (str): The path to the requirements file.
    Returns:
      A dictionary containing the requirements and their versions.
    """
    requirements_dict = {}

    with open(requirementPath, "r") as f:
        requirements = f.readlines()
        requirements = [requirement.strip() for requirement in requirements]
        requirements = [
            requirement
            for requirement in requirements
            if not re.match(r"^\s*(#.*)?$", requirement)
        ]

    for requirement in requirements:
        delimiters = ["==", "<", ">", "<=", ">="]
        for delimiter in delimiters:
            if delimiter in requirement:
                key, value = requirement.split(delimiter, 1)
                requirements_dict[key] = value
                break
    return requirements_dict

def downloadWheelFromArtifactory(wheel_name: str, artifactory_wheels: list) -> None:
    """
    Download wheel from Artifactory based on the provided wheel name.
    Parameters:
      wheel_name (str): The name of the wheel to download.
      artifactory_wheels (list): A list of wheel names in Artifactory.
    Returns:
        None
    """
    regex = re.compile(wheel_name)
    bool_artifact_found = False

    for artifactory_wheel in artifactory_wheels:
        if regex.search(artifactory_wheel):
            print(f"{artifactory_wheel} found in Artifactory. Downloading...")
            command = f'wget --header="Authorization:Bearer {ARTIFACTORY_TOKEN}" "{ARTIFACTORY_URL}/{artifactory_wheel}" -P {destination}'
            os.system(command)
            print(f"Finished downloading {wheel_name} from Artifactory.")
            bool_artifact_found = True
            break
    if bool_artifact_found == False:
        print(f"{wheel_name} does not exist in Artifactory.\nPlease make sure all the pre build pacakges are available in artifactory before running this script.\nExiting...")
        print("Please upload the necesessary packages that are missing in the artifatory using the repo https://github.ibm.com/maximoappsuite/python-Zwheel.")
        exit(1)

# ************************************************************************************************************#
# SCRIPT STARTS HERE
# ************************************************************************************************************#

# Create a list of requirements to fetch the versions for packages mentioned in preBuiltPackages
extra_index_url = "na.artifactory.swg-devops.com/artifactory/api/pypi/wiotp-pypi-local/simple"
command = f"python3 -m pip install --ignore-installed --dry-run -r {requirementPath} --report requirements_report.json --extra-index-url https://{W3_USERNAME}:{ARTIFACTORY_TOKEN}@{extra_index_url}"
print(command)
os.system(command)

# Extract the version from requirements_report.json file
if os.path.isfile("requirements_report.json"):
    f = open("requirements_report.json")
    requirements_report = json.load(f)

    for installed_package in requirements_report.get("install", []):
        metadata = installed_package.get("metadata", {})
        package_name = metadata.get("name")
        package_version = metadata.get("version")
        if package_name in prebuiltpackages:
            prebuiltpackages[package_name] = package_version
else:
    print(f"Failed to generate the requirements_report.json file.\nError in command: python3 -m pip install --ignore-installed --dry-run -r {requirementPath} --report requirements_report.json")
    exit(1)

# Parse the requirements.txt file passed as argument to the script (need to be sent while running the script as argument).
requirements_dict = parserequirementsFile(requirementPath)

# Fetch the html content with list of all wheels present in the artifactory location.
command = f'wget -q --header="Authorization:Bearer {ARTIFACTORY_TOKEN}" "{ARTIFACTORY_URL}" -O artifactory_list.txt'
os.system(command)

# If we are able to fetch the HTML contents, parse its contents to generate the list of all wheels available in artifactory.
if os.path.isfile("artifactory_list.txt"):
    f = open("artifactory_list.txt", "r")
    parser = MyHTMLParser()
    parser.feed(f.read())
    artifactory_wheels = parser.data
else:
    print(f"Failed to retrieve directory listing.")
    exit(1)

for pb_package_name in prebuiltpackages:
    pb_package_v = prebuiltpackages[pb_package_name]

    if pb_package_name in requirements_dict:
        # If the package is mentioned in requirements.txt, fetch the version from dictionary.
        version = requirements_dict[pb_package_name]
        print(
            f"{pb_package_name}-{version} from prebuiltpackages exists in {requirementPath}"
        )

        wheel_name = f"{pb_package_name}-{version}"
        downloadWheelFromArtifactory(wheel_name, artifactory_wheels)

    else:
        if pb_package_v == 'None':
            print(f"The package {pb_package_name} has no version specified in {requirementPath}. Please add the version for {pb_package_name} in {requirementPath}")
            print("Exiting...")
            exit(1)

        wheel_name = f"{pb_package_name}-{pb_package_v}"
        print(
            f"{wheel_name} from prebuiltpackages does not exist in {requirementPath}. Downloading {wheel_name}"
        )
        downloadWheelFromArtifactory(wheel_name, artifactory_wheels)