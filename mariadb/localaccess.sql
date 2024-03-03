/* Remove the password for root@localhost so mysqladmin ping works */
SET PASSWORD FOR root@localhost='';
