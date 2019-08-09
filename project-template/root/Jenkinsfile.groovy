pipeline {

  agent {
          label "ios"
  }

  //agent any

  environment {
    IS_RELEASE = "${(branch == 'master')}"
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {

    stage('Git checkout') {
      steps {
          sh "echo '##Chosen Branch : ${branch}##'"
          checkout([$class                           : 'GitSCM',
                    branches                         : [[name: "${branch}"]],
                    doGenerateSubmoduleConfigurations: false,
                    extensions                       : [[$class: 'CleanCheckout']],
                    gitTool                          : 'Default',
                    submoduleCfg                     : [],
                    userRemoteConfigs                : [[credentialsId: 'svc-qpjenkins-egbbk',
                                                         name         : 'origin',
                                                         url          : 'ssh://git@egbitbucket.dtvops
                                                         .net:7999/templateproj/templaterepo.git']]
          ])
      }
    }

    //Build Libraries and Publish to Maven Local
    stage('Build Libraries') {
      steps {
          sh "./gradlew publishLibrariesToMavenLocal -PisRelease=$IS_RELEASE"
      }
    }

    //Publish the Build artifacts to specified Maven Repository
    stage('Publish') {
      environment {
          NEXUS_CREDS = credentials('svc-jenkins-nexus-cicd')
      }
      steps {
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
              sh "./gradlew bumpVersionAndTag -PisRelease=$IS_RELEASE"
          }
      }
    }

  }
}
