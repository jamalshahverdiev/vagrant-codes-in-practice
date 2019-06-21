#!/usr/bin/env bash

mvn archetype:generate -DgroupId=com.opensource.app -DartifactId=newapp -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
cd newapp && mvn package && ls -la target/

