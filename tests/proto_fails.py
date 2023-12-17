from datetime import datetime

from tests.proto.example.v1 import example_pb2

if __name__ == "__main__":
    example = example_pb2.Example(
        id=1,
        value="example",
        created=datetime.now(),
    )
