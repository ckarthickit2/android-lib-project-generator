# NexGen Project Template Generation Tool

![platform_badge](https://img.shields.io/badge/platform-android-brightgreen)
![tools_badge](https://img.shields.io/badge/tools-spotless%2C%20detekt%2C%20dokka-informational)

---

## &#9875; Template Project Generation

1. Create a __new__ folder for the `Android Library Project`, that is being setup.
2. Clone the toolset repository __inside the newly created folder.__

    ```bash
      git clone ssh://git@domain:port/repo_path.git ./toolset
    ```

3. Get into the `toolset` folder and execute the `./createProjTemplate.sh` script to setup the basic template project
    - The script takes the following __mandatory parameters__
      1. `Group Name` (should be a __valid JAVA Package identifier__)
      2. `Library/Artifact Name` (should be a __valid alphanumeric value that can optionally be hyphenated__)

    ```bash
      ./createProjTemplate.sh -g com.example.sample -l foundation
    ```

    Once the above steps are successfull, a new project with a template folder structure will be created and `toolset` will be added as submodule of the base project.
4. Open the `Jenkinsfile.groovy` pipeline file and update the appropriate git remote for the created repository.

    ```groovy
      checkout([
      //....
      url   : 'ssh://git@domain:port/repo_path.git'
      //...
      ]
    ```

5. Stage all the files, commit and push it to the above mentioned remote.
6. Create a Multi-Branch Jenkins Pipeline and configure the above mentioned repository

The repository is now ready with all `bikeshedding work` configured.

## &#9875; A typical top-level directory layout

    .
    ├── lib                     # An `android-library` sub-project containing actual implementation.
    ├── sample                  # An `android-application` to instrument/verify library functionalities.
    ├── toolset              # Contains common dependencies and tools used across projects.
    ├── build.gradle            # Root Project's `build.gradle` that applies tools from `toolset`.
    ├── settings.gradle         # Includes `lib` and `sample` sub-projects for compilation. 
    ├── gradle.properties       # Contains default properties for the project.
    ├── Jenkinsfile.groovy      # Configures Jenkins Pipeline
    └── README.md               # Created to update context about Project

## &#128193; `lib` sub-project

All the actual implementation of the Library goes inside this folder.  
This will generate an Android Archive which can be published to any maven repository

### &#9881; `<LibraryName>`LibraryInfo.kt

Maintains the library versioning.

  ```kotlin
    /**
    * The Major version of the library
    */
    @SuppressWarnings("unused")
    const val MAJOR_VERSION: Int = 1
    /**
    * The Minor version of the library
    */
    @SuppressWarnings("unused")
    const val MINOR_VERSION: Int = 1
    /**
    * The Path version of the library
    */
    @SuppressWarnings("unused")
    const val PATCH_VERSION: Int = 0
  ```

On every `push` to master

  1. a build is triggerred,
  2. current version is tagged
  3. and the __PATCH_VERSION__ is upgraded in this file

> __MAJOR_VERSION__ and __MINOR_VERSION__ has to be manually upgraded when necessary.

### &#9881; library.properties

A `property file` that has the following details on the library

1. `groupID` - The Group ID under which the artifact needs to be published
2. `artifactID` - The name of the artifact file
3. `libraryInfoPath` - The `relative path` to the __LibraryInfo__ class file from the library folder.

### &#9881; publish.properties

A `property file` that contains the details about the maven repositories to which the artifact should be published

1. `repositoryNames` - List of Maven Repository Names seperated by __semi-colon (;)__
2. `snapshotURLs` - List of Snapshot URLs with positions corresponding to the repositoryNames specified above
3. `releaseURLs` - List of Release URLs with positions corresponding to the repositoryNames specified above
4. `credentials` - List of Credentials for Maven Repository with positions corresponding to the repositoryNames specified above. If no crendentials are needed, __a place holder (null;)__ MUST be used.

## &#128193; `toolset` submodule(&#128279;)

This __MUST__ be a `submodule` of the created library project and should be one of the top-level directories of the project.
It contains the following:

- `classpath of all the gradle plugins` used commonly across projects.
- `configuration for all the bike-shedding tools`(&#128736;) used.

## &#128747; Jenkinsfile.groovy

This file is configured for compiling and publishing the artifacts to maven.  
Currently this is configured to EG Nexus and Maven Repositories.  
This can be changed if we need to migrate to a different environment.

&#128679;&#127959;

## &#128679; Technical Debts

- [ ] Generate `lib-sources` artifact and publish to Maven.
- [ ] Stream Edit Jenkins Pipeline by taking `remote-url` as input.
- [ ] Generate `lib-documentation` artifact and publish to Maven.

---
[unicode_emoji_list]: http://www.unicode.org/emoji/charts/full-emoji-list.html
