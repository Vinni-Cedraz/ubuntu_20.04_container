## INSTALL

#### Se vc ta na 42 clone esse repo no seu diretório goinfre

##### Dentro do diretório do dockerfile execute esses comandos em ordem:

- 1 execute `./execute_me.sh`
- 2 a sessão vai abrir, configure o powerlevel 10k seguindo as instruções que
  aparecem na tela e depois disso saia do container digitando `exit` no terminal
  dele
- 3 execute `docker start my_ubuntu_container`

* agora seu container está criado e inicializado, para abrir ele e continuar de onde parou execute:

`docker exec -it my_ubuntu_container zsh`

Eu sugiro vc criar um alias para o comando acima, algo como `ubuntu_exec`.
Pra fazer isso vc poder adicionar essa linha aqui no seu .zshrc: 

`alias ubuntu_exec="docker exec -it my_ubuntu_container zsh"`

* Blz, vc pode entrar sempre que quiser usando teu alias e vai encontrar
  no container tudo do jeito que estava antes:

* para sair:
`exit`
* para entrar (apos colocar o alias):
`ubuntu_exec`
 
## IMPORTANTE:
dentro do .zshrc do container (que pode ser acessado simplesmente com o alias
zshrc) voce precisa mudar as configuirações que estão na seção do header da 42
pra usar com os seus dados:

```
# 42 header:
export USER='vcedraz-'
export MAIL='vcedraz-@student.42sp.org.br'
#42 header end;
```

## DELETANDO TUDO


Por fim, se por algum motivo quiser excluir tudo execute esses comandos aqui em sequencia:

`docker stop my_ubuntu_container`
`docker rm my_ubuntu_container`
`docker system prune -a --force --volumes`
