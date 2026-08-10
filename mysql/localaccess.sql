/* Remove the password for root@localhost so mysqladmin ping works */
ALTER USER 'root'@'localhost' IDENTIFIED BY '';
