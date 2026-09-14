# Globus token (does not work anymore, see instructions for SF API tokens)

python get_globus_token.py --print-token

Open this URL, login, and consent:
[Go to printed URL, and copy authorization code]

# Superfacility API Token

https://docs.nersc.gov/services/sfapi/authentication/#authentication 

Go to Iris NERSC, account, scroll to bottom, add client, need to provide IP addresses of machines 

Copy keys 

Use the whole dictionary of private key as private_key in the following script 

pip install authlib

python get_sf_token.py

This prints the token valid for 10 minutes. 
This token can be used in the Swagger UI https://api.iri.nersc.gov/#/compute/getJobs 
to query the API through web interface. Also generates a curl command that can be 
copied and executed on command line.

# Accessing IRI API with curl
curl -X GET "https://api.iri.nersc.gov/api/v1/status/resources?offset=0&limit=100&modified_since=2020-02-21T12%3A00%3A00Z" -H "accept: application/json" -H "Authorization: Bearer $(python get_sf_token.py)" | jq

curl -X GET "https://api.iri.nersc.gov/api/v1/account/projects" -H "accept: application/json" -H "Authorization: Bearer $(python get_sf_token.py)"


# March 16
## UPLOAD

curl -X POST \
  "https://api.iri.nersc.gov/api/v1/filesystem/upload/43d8f6c0-f900-48ce-b267-73714103f4ac?path=%2Fpscratch%2Fsd%2Fa%2Fatif%2F" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $(python get_sf_token.py)" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@upload_to_perlmutter.py;type=text/x-python-script"

## DOWNLOAD

curl -X GET \
  "https://api.iri.nersc.gov/api/v1/filesystem/download/43d8f6c0-f900-48ce-b267-73714103f4ac?path=%2Fpscratch%2Fsd%2Fa%2Fatif%2Ffm4npp%2Famsc-d2%2Ftrack_ids.npz" \
  -H "accept: application/json" \
  -H "Authorization: Bearer $(python get_sf_token.py)"

# # Watch returned URI with

curl -H "Authorization: Bearer $(python get_sf_token.py)" "https://api.iri.nersc.gov/api/v1/task/<task_id>"

# SUBMIT JOB: Not yet tested

curl -X 'POST' \
  'https://api.iri.nersc.gov/api/v1/compute/job/94351904-6dba-4c16-b5cd-fbd280d8615b' \
  -H 'accept: application/json' \
  -H "Authorization: Bearer $(python get_sf_token.py)" \
  -H 'Content-Type: application/json' \
  -d '{
  "executable": "/pscratch/sd/a/atif/amsc-suf-ip/amsc-suf-ip/bin/python",
  "container": {},
  "arguments": [
    "/pscratch/sd/a/atif/fm4npp/amsc-d2/amsc_d2.py"
  ],
  "directory": "/pscratch/sd/a/atif/fm4npp/amsc-d2/",
  "name": "my-job",
  "inherit_environment": true,
  "environment": {
    "OMP_NUM_THREADS": "1"
  },
  "stdout_path": "/pscratch/sd/a/atif/fm4npp/amsc-d2/output.txt",
  "stderr_path": "/pscratch/sd/a/atif/fm4npp/amsc-d2/error.txt",
  "resources": {
    "node_count": 1,
    "process_count": 1,
    "processes_per_node": 1,
    "cpu_cores_per_process": 1,
    "gpu_cores_per_process": 0,
    "exclusive_node_use": false,
    "memory": 17179869184,
    "additionalProp1": {}
  },
  "attributes": {
    "duration": 30,
    "queue_name": "debug",
    "account": "m4402",
    "reservation_id": "resv-42",
    "custom_attributes": {
      "constraint": "cpu"
    },
    "additionalProp1": {}
  },
  "pre_launch": "",
  "post_launch": "echo done",
  "launcher": "srun"
}'

# Accessing with Python Client

pip install iri_client

python python_iri_client.py

Perlmutter Compute
94351904-6dba-4c16-b5cd-fbd280d8615b

(Simpler) works
curl -X POST   "https://api.iri.nersc.gov/api/v1/filesystem/upload/84b8d5d0-6ce0-4f40-b0e7-c81969da4f9b?path=/global/homes/a/atif/noise_tags.npz"   -H "accept: application/json"   -H "Authorization: Bearer $(python get_sf_token.py)"   -F "file=@test/noise_tags.npz;type=text/x-python-script"


