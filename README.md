# openelis-ai-platform

### Run OpenELIS Global

    docker compose -f ./projects/openelis/docker-compose.yml  up -d

Aacces OpenELIS Global at https://localhost/  with  `admin: adminADMIN!`

### Run FHIR pipes 

    docker compose -f ./projects/fhirpipes/docker-compose.yaml  up -d

Acees Pipeline Controller at  http://localhost:8090/

#### Connection to  to the spack DB
*  user name : hive 
* Port : 10001
* Passowrd : ""
* Databse : default


