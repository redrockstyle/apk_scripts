#!/bin/bash

# Get Burp Certificate
curl -s --proxy 0.0.0.0:8080 http://burpsuite/cert --output -