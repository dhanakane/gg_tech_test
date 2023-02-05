# GetGround Take Home Test

## How to run this assignment

### Pre-requisites
- Working minikube installation
- Helm
- Git

1. Clone the git repo [here](git@github.com:dhanakane/gg_tech_test.git)
2. Install the Helm chart with `helm install myapp ggapp`
3. Verify all pods are running with `kubectl get pods`
4. Forward traffic to the application service with `kubectl port-forward
   --service=app 8080:8080` Alternatively, use minikube to generate a URL for
   the service with `minikube service app --url` and make a note of the URL
   generated.
5. Visit the URI you'd like to test the application with, e.g: `curl
   <APP-URL>:<APP-PORT>/23423` (e.g: `curl http://localhost:8080/1` and verify
   the count returned. Repeat the query a few times and test the count is
   incremented.

## Summary

The finished submission is a set of Helm charts using an umbrella pattern to
simplify deployment. The subcharts comprise app and database charts. The app
deployment relies on using multiple replica pods to guarantee high
availability. The db chart relies on running redis in a master/slave
configuration to guarantee high availability.

## Context on approach and process

### MVP with docker and docker-compose
I approached the task with an SRE mindset. Typical scenarios this covers is
where application code is handed over with a minimal implementation, and SRE
need to figure out the scalability and reliability concerns. To simulate this,
I implemented a PoC with docker-compose with a 2 tier architecture, using
application and database tiers. The application tier hosted the Golang
application container, the database tier hosted a single redis database
container. This allowed me to debug issues with the application and prove it
worked before committing more time to getting Kubernetes setup and running.

### Optimisations
The application was containerised using the builder pattern in order to slim
down the image to only include the image binary. This is useful for addressing
both security and efficiency concerns.

### Moving to K8s from docker-compose I then moved on to figuring out how to
"kubernetise" the application. A quick way to move from a docker-compose file
to a functional K8s deployment was to use a tool like
[kompose](https://github.com/kubernetes/kompose) which takes a docker-compose
file as input and outputs a K8s manifest. This allowed me to maintain a working
MVP and save time trying to figure out Kubernetes manifests from first
principles.

### K8s platform selection
I then chose [minikube](https://minikube.sigs.k8s.io/docs/) as a platform to
develop and test the generated manifest. Other alternatives I considered and
discarded were setting up a managed K8s service, or setting up K8s on Vagrant
due to potential cost and time. Given more time, these would have been doable.

### Moving to Helm from K8s manifests to Helm
From here, I moved to packaging the installation using Helm to simplify
deployments (manually applying K8s manifests in order becomes very tiresome
quickly). Manifests were also refactored to remove unrequired configuration
introduced by kompose.

### Refactoring Helm
I started with a single, flat Helm chart before moving to an umbrella chart
pattern. This would simplify the introduction of additional components when
necessary while keeping the code clean. For example, adding a frontend would
simply require the development and addition of a frontend chart.

### Refactoring the db Helm chart
The database layer was also converted to become highly available, and use
StatefulSets in combination with a headless Service at this point.

### Exposing the application
At this point, I had a working, highly available, easy to deploy assignment.
Access to the application can be tested by performing port forwarding to the
application service and verifying a request returns a count.

## Possible improvements/TODOS

### Application
- Add unit and integration tests.
- Add a healthcheck URI endpoint.

### Database deployment
- Redis needs to use sentinel in order to detect and failover in case the
  master server fails. Currently, my understanding is that the failure of the
  master node will result in writes failing. So, the application will not be
  able to write for the duration it takes for the `redis-0` pod to recover in
  case of failure.

### Infrastructure deployment
- Refactor Helm charts to use `values.yaml` files to simplify future changes.
- Introduce a method to test failover. I'm currently having to take it on faith
  that K8s will handle failover. A tool like
  [Gremlin](https://www.gremlin.com/community/tutorials/how-to-test-your-high-availability-ha-kubernetes-cluster-using-gremlin/)
  could assist with verifying this.
- Add a test hook in Helm to run a readiness test on the pods.
- Add periodic builds via CI for the application Docker image so it is kept up to date.
- Add security scanning for the Docker images used.
