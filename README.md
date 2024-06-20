# Campainha Inteligente
Trabalho dos alunos do curso de Ciência da Computação da PUC Minas para a disciplina "Trabalho Interdisciplinar VI: Sistemas Paralelos e Distribuídos".

## Integrantes
- Caio Henrique Alvarenga Gonçalves
- Felipe Augusto Maciel Constantino
- João Gabriel Polonio Teixeira
- Thiago Utsch Andrade
- Uriel do Carmo Andrade
## Sobre o Sistema
O sistema é um protótipo de software para um dispositivo IoT que funciona como uma campainha inteligente. Ele é capaz de identificar e liberar acesso automaticamente para moradores de um local, além de notificar usuários quando visitantes, conhecidos ou desconhecidos, estão em sua porta.

## Funcionamento
A partir de um front-end desenvolvido em Flutter, que pode ser usado tanto no dispositivo IoT quanto nos smartphones dos usuários, o sistema faz chamadas para uma API em Python. Esta API recebe uma foto do rosto de quem está tocando a campainha e, utilizando a biblioteca DeepFace, reconhece se o rosto pertence a um morador, visitante conhecido ou desconhecido.

Para moradores, a ideia é que o dispositivo IoT libere o acesso automaticamente. No caso de visitantes conhecidos, uma notificação é enviada para o aplicativo do usuário, informando o nome e a foto do visitante, perguntando se o acesso deve ser liberado. Se a pessoa for desconhecida, a foto também é enviada ao usuário com as mesmas opções anteriores, além da possibilidade de registrar a pessoa desconhecida como um morador ou conhecido.
