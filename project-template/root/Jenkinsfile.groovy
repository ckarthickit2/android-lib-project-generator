pipeline {

  agent {
    label "ios"
  }

  //agent any

  environment {
    IS_RELEASE = "${(BRANCH_NAME == 'master')}"
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {

    stage('Git checkout') {
      steps {
        echo "##Building Branch : $BRANCH_NAME##"
        checkout([$class                           : 'GitSCM',
                  branches                         : [[name: "$BRANCH_NAME"]],
                  doGenerateSubmoduleConfigurations: false,
                  extensions                       : [[$class: 'CleanCheckout']],
                  gitTool                          : 'Default',
                  submoduleCfg                     : [],
                  userRemoteConfigs                : [[credentialsId: 'svc-qpjenkins-egbbk',
                                                       name         : 'origin',
                                                       url          : 'ssh://git@domain:port/repo_path.git']]
        ])
      }
    }

    //Build Libraries and Publish to Maven Local
    stage('Build Libraries') {
      steps {
        //sh  "yes | $ANDROID_HOME/tools/bin/sdkmanager build-tools;29.0.1"
        sh "git submodule update --recursive"
        sh "./gradlew clean && ./gradlew assemble -PisRelease=$IS_RELEASE"
      }
    }

    //Publish the Build artifacts to specified Maven Repository
    stage('Publish') {
      environment {
        NEXUS_CREDS = credentials('svc-jenkins-nexus-cicd')
      }
      steps {
        sh "uname -a"
        sh "./gradlew publish -PisRelease=$IS_RELEASE -PnexusUsername=$NEXUS_CREDS_USR -PnexusPassword=$NEXUS_CREDS_PSW"
      }
    }

    //Bump Up the version and commit a Tag to Git
    stage('Bump Version') {
      when {
        //branch 'master' //Works only for multibranch pipeline
        environment name: 'IS_RELEASE', value: 'true'
      }
      steps {
        sshagent(['svc-qpjenkins-egbbk']) {
          sh "./gradlew tagAndBumpVersion -PisRelease=$IS_RELEASE -PbranchName=$BRANCH_NAME"
        }
      }
    }

  }
}
