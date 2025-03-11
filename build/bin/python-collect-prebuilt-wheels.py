#!/usr/bin/env python3
#
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
    "--target-platform", type=str, required=False, help="Architecture of the target platform"
)
parser.add_argument(
    "--python-version", type=str, required=False, help="Specifies if a python version other than one installed on the system should be used to generate the package dependency report"
)

# We are keeping --add-dependency and --no-default-crypto for now so that nothing breaks while we do the transition across all the repos which use this script
# But we won't be using these parameter going forward
# TODO: REMOVE THESE ARGUMENTS AFTER THE TRANSITION IS COMPLETE.
parser.add_argument(
    "--add-dependency", type=str, required=False, help="Additional dependencies that are image specific. Use ',' for multiple dependencies"
)

parser.add_argument(
    "--no-default-crypto", action='store_true', help="If this paf is set, cryptogrpahy will not be added to the default list of requirements"
)

args = parser.parse_args()

requirementPath, destination, target_platform, python_version = args.req_file, args.dest, args.target_platform, args.python_version

if target_platform != None:
    ARTIFACTORY_URL = f"https://na.artifactory.swg-devops.com/artifactory/wiotp-generic-local/dependencies/wheels/{target_platform}"
else:
    ARTIFACTORY_URL = f"https://na.artifactory.swg-devops.com/artifactory/wiotp-generic-local/dependencies/wheels/s390x"

W3_USERNAME, ARTIFACTORY_TOKEN = os.environ["W3_USERNAME"], os.environ["ARTIFACTORY_TOKEN"]

# required_packages: Dictionary that contains packages and their version that we will fetch from requirements_report.json.
required_packages = {}

# artifactory_wheels: List of all the packages that are already uploaded to artifactory.
artifactory_wheels = []

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

    for artifactory_wheel in artifactory_wheels:
        if regex.search(artifactory_wheel):
            print(f"Downloading {artifactory_wheel} from artifactory...")
            command = f'wget --header="Authorization:Bearer {ARTIFACTORY_TOKEN}" "{ARTIFACTORY_URL}/{artifactory_wheel}" -P {destination}'
            os.system(command)
            print(f"Finished downloading {artifactory_wheel} from Artifactory.\n")

# ************************************************************************************************************#
# SCRIPT STARTS HERE
# ************************************************************************************************************#

# Generate a requirements_report.json file for the given requirements.txt file
extra_index_url = f"--extra-index-url https://{W3_USERNAME}:{ARTIFACTORY_TOKEN}@na.artifactory.swg-devops.com/artifactory/api/pypi/wiotp-pypi-local/simple"
base_command = f"python3 -m pip install  --ignore-installed --dry-run -r {requirementPath} --report requirements_report.json {extra_index_url}"
if python_version == None:
    command = base_command
else:
    command = f"{base_command} --python-version {python_version } --only-binary=:all:"

print(command)
os.system(command)

# Extract the version from requirements_report.json file
if os.path.isfile("requirements_report.json"):
    f = open("requirements_report.json")
    requirements_report = json.load(f)

    for required_package in requirements_report.get("install", []):
        metadata = required_package.get("metadata", {})
        package_name = metadata.get("name")
        package_version = metadata.get("version")
        required_packages[package_name] = package_version
else:
    print(f"Failed to generate the requirements_report.json file.\nError in command: python3 -m pip install --ignore-installed --dry-run -r {requirementPath} --report requirements_report.json")
    exit(1)

# Fetch the html content of all the wheel packages available in the artifactory location
command = f'wget -q --header="Authorization:Bearer {ARTIFACTORY_TOKEN}" "{ARTIFACTORY_URL}" -O artifactory_list.txt'
os.system(command)

# If we are able to fetch the HTML contents, parse its contents to generate the list of all wheels available in artifactory
if os.path.isfile("artifactory_list.txt"):
    f = open("artifactory_list.txt", "r")
    parser = MyHTMLParser()
    parser.feed(f.read())
    artifactory_wheels = parser.data
else:
    print(f"Failed to retrieve directory listing.")
    exit(1)

print(f"Looking for all the available prebuiltwheel packages in {ARTIFACTORY_URL}")
for pb_package_name in required_packages:
    pb_package_v = required_packages[pb_package_name]

    if "-" in pb_package_name:
        pb_package_name = pb_package_name.replace("-", "_")
    wheel_name = f"{pb_package_name}-{pb_package_v}"
    downloadWheelFromArtifactory(wheel_name, artifactory_wheels)