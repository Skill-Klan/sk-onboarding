#!/bin/bash
echo "Тестую порти..."
timeout 5 bash -c "</dev/tcp/37.57.209.201/22" && echo "Порт 22 відкритий" || echo "Порт 22 закритий"
