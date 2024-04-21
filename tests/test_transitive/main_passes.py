import pandas as pd

from tests.test_transitive.square.square_passes import square

if __name__ == "__main__":
    print(square(pd.DataFrame(data={"abc": list(range(5))})))
