# postman-test-validate-spring-cloud-configuration
Docker image for validating ConnectionFactory created are not overriden for spring cloud projects.


## What
Docker image for validating ConnectionFactory created for spring cloud projects.
Base image is - newman-postman.

## Why
By default spring cloud migrated projects should have property as follows to notify the application about configuration changes.
`spring.rabbitmq.host=configbus.mgmt.mytaxi.com`.
This docker image has POSTMAN TESTS which runs and validates the prelive and live environment has not overriden this property.
Overriding this property will create issues with notifying config changes to app.

## How
Create a task and add to DefaultPlan in bamboo spec in case missing.
   
    private static DockerRunContainerTask getCloudConfigurationPostmanTest()
    {
        return new DockerRunContainerTask()
            .description("Check spring.rabbitmq.host mapped to config server")
            .imageName("docker.intapps.it/configservertest:latest")
            .serviceURLPattern("http://localhost:${docker.port}")
            .containerCommand("run api.json --global-var \"servicename=bookingoptionsservice\"")
            .containerWorkingDirectory("/etc/newman")
            .clearVolumeMappings();
    }
     private static Stage getDefaultStage()
    {
        return new Stage("Default Stage")
            .jobs(new Job(
                "Default Job",
                new BambooKey("JOB1"))
                .tasks(
                    getCloudConfigurationPostmanTest(),
                    getVcsCheckoutTask(),
                    getVerifyAndExecuteTestsTask(),
                    getRemoveSnapshotFromPomTask(),
                    getSonarQubeTask(),
                    getMasterReleaseTask(),
                    getDockerContainerTask())
                .finalTasks(
                    getExtractTestResultsTask()
                )
            );
    }


OR use following commands to test

`docker build configservertest:latest .`
`docker configservertest:latest run api.json --global-var “servicename={{ANY_SERVICE_NAME}}”`
