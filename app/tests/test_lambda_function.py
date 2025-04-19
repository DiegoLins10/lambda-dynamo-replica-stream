import pytest
import app.lambda_function as lf

def test_lambda_handler():
    event = {}
    context = None
    response = lf.lambda_handler(event, context)
    assert response["statusCode"] == 200
