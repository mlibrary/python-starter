import sys


def hello():
    print('Hello, world!')
    print(sys.version)
    print(sys.executable)
    print("Hello, I am in main.py")
    print(sys.version_info)


if __name__ == '__main__':
    hello()
