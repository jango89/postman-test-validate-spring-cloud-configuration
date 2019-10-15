## What
Postman Tests for validating   
	1. ConnectionFactory created for spring cloud projects.    
    2. Test webhook is created in the configuration project.    
Base image is - newman-postman.

## Why
1. By default spring cloud migrated projects should have property as follows to notify the application about configuration changes.
`spring.rabbitmq.host=configbus.mgmt.mytaxi.com`.
This docker image has POSTMAN TESTS which runs and validates the prelive and live environment has not overriden this property.
Overriding this property will create issues with notifying config changes to app.

2. Spring cloud also needs a webhook in the configuration repository for listening to config file changes. 
The test also checks min 1 webhook is present in the configuration repository.


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

`docker run --rm docker.intapps.it/configservertest:latest run api.json --global-var “servicename={{ANY_SERVICE_NAME}}”`
