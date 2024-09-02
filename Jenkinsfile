pipeline {

agent any

environment {

GCP_PROJECT = ' devops-2024’

GCE_INSTANCE = 'Jenkins-server'

GCE_ZONE = 'us-central1-a'

}

stages {

stage('Pull') {

steps {

git branch: 'main', url: 'https://github.com/gravityer-repo/v1-app.git'

}

}

stage('Build') {

steps {

sh 'docker build -t gcr.io/$GCP_PROJECT/v1-app .'

}

}

stage('Test') {

steps {

sh 'docker run --rm gcr.io/$GCP_PROJECT/v1-app ./run_tests.sh'

}

}

stage('Deploy') {

steps {

sh 'gcloud compute scp --recurse --zone=$GCE_ZONE ./your-app $GCE_INSTANCE:/var/www/html'

sh 'gcloud compute ssh --zone=$GCE_ZONE $GCE_INSTANCE --command "sudo systemctl restart nginx"'

}

}

}

post {

always {

cleanWs()

}

}

}
