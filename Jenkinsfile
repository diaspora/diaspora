node('node') {
    currentBuild.result = "SUCCESS"
    try {
       stage('Checkout'){
          checkout scm
       }
        stage('Test'){
       }
        stage('Build Docker'){
       }
        stage('Deploy'){
       }
        stage('Cleanup'){
       }
    }
    catch (err) {
        currentBuild.result = "FAILURE"
        throw err
    }
}
