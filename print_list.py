from iri_client import Client

for op in Client.operations():
    if op.operation_id == "ls":
        print(op.method, op.path_template)


from iri_client import Client

ops = Client.operations()
for op in ops:
    oid = op.operation_id.lower()
    if any(k in oid for k in ["upload", "put", "write", "create", "filesystem", "file"]):
        print(f"{op.operation_id:30s} {op.method:6s} {op.path_template}")
