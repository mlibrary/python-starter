# Remove this tests directory if you want to have tests inline with production
# code
from python_starter.sample import Sample

def test_add_one():
    assert Sample().add_one(21) == 22