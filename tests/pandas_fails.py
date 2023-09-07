import pandas as pd


def square(data: pd.DataFrame) -> pd.Series:
    return data**2


if __name__ == "__main__":
    print(square(pd.DataFrame(data={"values": list(range(10))})))
