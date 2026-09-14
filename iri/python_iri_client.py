import json
from iri_client import Client

client = Client(base_url="https://api.iri.nersc.gov")

# List operation ids
operations = Client.operations()
print(f"Loaded {len(operations)} operations from generated catalog")
print("First 10 operations:")
for operation in operations[:]:
    print(f"  - {operation.operation_id} ({operation.method} {operation.path_template})")

# Public operation
print(client.call_operation("getFacility"))

print("getSite")
# Path params
paths = client.call_operation(
        "getSite",
        path_params_json=json.dumps({"site_id": "dd7f822a-3ad2-54ae-bddb-796ee07bd206"}),
        )
print(paths)


# Ask for Perlmutter compute resources
resp = client.call_operation(
    "getResources",
    #query_params_json=json.dumps({
    #    "limit": "100",
    #    "offset": "0",
    #    "group": "perlmutter",
    #    "resource_type": "compute",
    #}),
)
print("getResources")
print(resp)

print("getProjects")
# Auth-required operation
access_token = ""
auth_client = Client(base_url="https://api.iri.nersc.gov", access_token=access_token)
print(auth_client.call_operation("getProjects"))


rid = "84b8d5d0-6ce0-4f40-b0e7-c81969da4f9b"

resp_json = auth_client.call_operation(
    "ls",
    path_params_json=json.dumps({"resource_id": rid}),
    query_json=json.dumps({"path": "/global/homes/a/atif/"}),   # or "/global/homes/<your_user>"
)

print("ls")
print(json.dumps(json.loads(resp_json), indent=2))


