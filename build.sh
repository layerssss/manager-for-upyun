#!/bin/bash -e
middleman build
rm -Rf nodebob/app/*
mv build/* nodebob/app
cp -Rf public/* nodebob/app
