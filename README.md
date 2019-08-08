# NexGen Project Template Generation Tool

![platform_badge](https://img.shields.io/badge/platform-android-brightgreen)
![tools_badge](https://img.shields.io/badge/tools-spotless%2C%20detekt%2C%20dokka-informational)

---

## Template Project Generation

- Create a __new__ folder for the `Android Library Project` under setup.
- Clone the team-props repository __inside the newly folder.__

  ```bash
    git clone ssh://git@egbitbucket.dtvops.net:7999/b2bclientdev/nexgen-android-team-props.git ./team-props
  ```

- Get into the `team-props` folder and execute the `./createProjTemplate.sh` script to setup the basic template project
  - The script takes the following __mandatory parameters__
    1. `Group Name` (should be a __valid JAVA Package identifier__)
    2. `Library/Artifact Name` (should be a __valid alphanumeric value that can optionally be hyphenated__)

  ```bash
    ./createProjTemplate.sh -g com.quickplay.nexgen -l foundation
  ```
