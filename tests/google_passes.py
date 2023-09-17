import google.protobuf.message
from google.protobuf import empty_pb2


def has_field(proto: google.protobuf.message.Message, field: str) -> bool:
    return proto.HasField(field_name=field)


if __name__ == "__main__":
    empty = empty_pb2.Empty()
    has_field(proto=empty, field="xyz")
