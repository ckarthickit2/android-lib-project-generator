# NexGen Project Template Generation Tool

![platform_badge](https://img.shields.io/badge/platform-android-brightgreen)
![tools_badge](https://img.shields.io/badge/tools-spotless%2C%20detekt%2C%20dokka-informational)

---

## &#9875; Template Project Generation

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

Once the above steps are successfull, a new project with a template folder structure will be created and `team-props` will be added as submodule of the base project.

## &#9875; A typical top-level directory layout

    .
    ├── lib                     # An `android-library` sub-project containing actual implementation.
    ├── sample                  # An `android-application` to instrument/verify library functionalities.
    ├── team-props              # Contains common dependencies and tools used across projects.
    ├── build.gradle            # Root Project's `build.gradle` that applies tools from `team-props`.
    ├── settings.gradle         # Includes `lib` and `sample` sub-projects for compilation. 
    ├── gradle.properties       # Contains default properties for the project.
    ├── Jenkinsfile.groovy      # Configures Jenkins Pipeline
    └── README.md               # Created to update context about Project

## &#128193; `lib` sub-project

All the actual implementation of the Library goes inside this folder.  
This will generate an Android Archive which can be published to any maven repository

### &#9881; library.properties

A `property file` that has the following details on the library

1. `groupID` - The Group ID under which the artifact needs to be published
2. `artifactID` - The name of the artifact file
3. `majorVersion` - The major version of the artifact which should be __manually bumped if needed.__
4. `minorVersion` - The minor version of the artifact which should be __manually bumped if needed.__
5. `patchVersion` - The patch version of the artifact which should be __manually bumped if needed.__
6. `buildNumber` - __Auto incremented on every publish__ to maven repository

### &#9881; publish.properties

A `property file` that contains the details about the maven repositories to which the artifact should be published

1. `repositoryNames` - List of Maven Repository Names seperated by __semi-colon (;)__
2. `snapshotURLs` - List of Snapshot URLs with positions corresponding to the repositoryNames specified above
3. `releaseURLs` - List of Release URLs with positions corresponding to the repositoryNames specified above
4. `credentials` - List of Credentials for Maven Repository with positions corresponding to the repositoryNames specified above. If no crendentials are needed, __a place holder (null;)__ MUST be used.

## &#128279;&#128193; `team-props` submodule

This __MUST__ be a `submodule` of the created library project and should be one of the top-level directories of the project.
It contains the following:

- `classpath of all the gradle plugins` used commonly across projects.
- `configuration for all the bike-shedding tools`(&#128736;) used.

## &#128747; JenkinsFile

&#128679;&#127959;

## &#128679; Technical Debts

- [ ] Generate `lib-sources` artifact and publish to Maven.
- [ ] Stream Edit Jenkins Pipeline by taking `remote-url` as input.
- [ ] Generate `lib-documentation` artifact and publish to Maven.

---
[unicode_emoji_list]: http://www.unicode.org/emoji/charts/full-emoji-list.html
