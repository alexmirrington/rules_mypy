from datetime import datetime

from google.protobuf.timestamp_pb2 import Timestamp

from tests.proto.example.v1 import example_pb2

if __name__ == "__main__":
    example = example_pb2.Example(
        id=1,
        value="example",
        created=Timestamp(seconds=int(datetime.now().timestamp())),
    )
