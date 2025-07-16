import math
from PIL import Image
from pathlib import Path
from sys import argv

def optimal_grid(J: int):
    best = None
    for W in range(1, J + 1):
        H = math.ceil(J / W)
        area = W * H
        score = area - J + abs(W - H)
        if not best or score < best[0]:
            best = (score, W, H)
    return tuple([best[1], best[2]])

dim = {
    "1x": tuple([71, 95]),
    "2x": tuple([142, 190]),
}

valid_input = False
while not valid_input:
    J = input("Number of jokers> ")
    try:
        J = int(J)
        if "." not in str(J) and int(J) == abs(int(J)):
            valid_input = True
        else:
            valid_input = False
            print("ERR: Please enter an integer")
    except:
        valid_input = False
        print("ERR: Please enter an integer")

optimal_dim = optimal_grid(J)
size1x = tuple(optimal_dim[i] * dim["1x"][i] for i in range(2))
size2x = tuple(optimal_dim[i] * dim["2x"][i] for i in range(2))

canvas1x = Image.new(mode="RGBA", size=size1x, color=(0, 0, 0, 0))
canvas2x = Image.new(mode="RGBA", size=size2x, color=(0, 0, 0, 0))

canvas1x.save(Path(f"./assets/1x/{argv[1]}"))
canvas2x.save(Path(f"./assets/2x/{argv[1]}"))
