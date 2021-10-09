1. Run `script/diaspora-dev setup`
2. Run `script/diaspora-dev start -d`
3. Access docker web run `docker exec -it diasporadev_diaspora_1 bash`
4. Access docker mysql run `docker exec -it diasporadev_mysql_1 bash`
5. Run app `rails s -b 0.0.0.0 -p 33001`
