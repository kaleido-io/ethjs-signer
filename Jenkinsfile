node {
    def baseImageName = 'photic-docker-node'
    def targetImageName = 'photic-docker-ethjs-signer'
    def npmPackage = '@photic/ethjs-signer'
    
    checkout scm

    docker.withRegistry("https://${env.DOCKER_REGISTRY}", "${env.DOCKER_CREDENTIALS}") {

        stage("Pull $baseImageName") {
            def baseImage = docker.image("$baseImageName:latest")
            baseImage.pull()
            // Cannot use baseImage.tag due to https://github.com/jenkinsci/docker-workflow-plugin/pull/122 
            // baseImage.tag("$baseImageName:latest")
            sh "docker tag ${env.DOCKER_REGISTRY}/$baseImageName:latest $baseImageName:latest"
        }

        stage("Build $targetImageName") {
            customImage = docker.build("$targetImageName:${env.BUILD_ID}")
        }

        stage('Test module') {
            timeout(5){
                customImage.inside {
                    sh "npm install && npm test"
                }
            }
        }

        // The 'sha1' environment variable contains the branch details.
        // We only want to push if the branch is master (or origin/master etc.)
        if ("${env.sha1}".endsWith('master')) {
            stage('Push NPM module (master build)') {
                customImage.inside {
                    // Set the local package.json to the latest remote version, then patch
                    def npmVersion = "npm version --no-git-tag-version --allow-same-version"
                    sh "$npmVersion \$(npm show $npmPackage version) && $npmVersion patch && npm publish"
                }
            }
        }
    }
}
