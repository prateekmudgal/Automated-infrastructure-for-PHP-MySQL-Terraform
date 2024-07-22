# Task Description :

- Pick any sample application which includes some pages for login or signup and connect to DB.
- Use RDS for Database.
- Migrate DNS to Route53.
- Deploy that application in Elastic Beanstalk.
- Explore the types of EB environment tiers, their use case, and working flow.
- Implement an application that is using both tiers.
- Explore EB CLI and deploy the application via EB CLI.

---

Let's see how we can achieve it...

## Step 1 :
## Code

we have the code that can be used for login and signup pages in this repo which is written in PHP. It's going to connect to MySQL Database.

## Step 2 :
## RDS Database

- Navigate to `RDS` page on `AWS console`.
- Click on `create database`
- Choose `Standard create`
- Choose engine type ( in my case `MySQL` )
- Choose version
- Choose templates ( `Free tier` )
- Provide `DB instance identifier` name.
- Generate `Credentials` for DB.
- Choose `instance type` and `storage` according to your need.
- In `connectivity` choose VPC and other options according to your need, you can make your DB publicly accessible or not.
- Choose Security group and Authentication type.
- Create Database.

## Step 3 :
## Deploy code

- fork this repo in your account.
- change `DB_SERVER`, `DB_USERNAME`, `DB_PASSWORD` and `DB_NAME` in `config.php` file.
- Now Download the `ZIP file` of repo from your account.
- Navigate to `Elastic Beanstalk` page.
- Create an Application by providing some name.
- Create a new environment in that application.
- Choose `webserver environment`.
- Choose Application name and provide `Environment` name.
- Choose `Managed platform` and select `PHP` as platform.
- Create Environment.

> Once your environment is ready and in `healthy` state, you can see the endpoint to connect to it like http://samplephp-env.eba-fqgguvde.ap-south-1.elasticbeanstalk.com/

## Step 4 :
## SSL configuration

Once application is deployed successfully, we need to add SSL to it.

- Naviage to `environment page` and select your `env`.
- Navigate to `configuration` of environment.
- In the load balancer category.
- Add listeneres for `HTTPS` and add `SSL certificate` for the domain you have purchased.

> NOTE: you will need to add SSL certificates in `AWS Certificate Manager`, you can either import or can request for the certificates.

- Once you are done with SSL. you will get some DNS records for that certificate in `Domains` section of certificate. Add those DNS records to your `route53` DNS record table.

- Update your DNS table with the Appropriate records.

---
Now we are done with the task. But still we need to understand the concepts of Elastic Beanstalk environments and EB cli.

## QNA :

## `What are Elastic Beanstalk environments ?`

There are 2 environments in EB :

1. Webserver 
2. Worker

let's understand both of these :

## Webserver
> Webserver environment is used to deploy the applications which are too quick and don't perform any long running tasks in backend.


![Elastic Beanstalk Webserver Environment](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/images/aeb-architecture2.png "Elastic Beanstalk Webserver Environment")


## Worker
> Worker environment works collaboratively with webserver environment. webserver environment runs the frontend part and worker env is used to operate backend task which takes time. Requets from webserver env is sent to `SQS` services and these requests are resolved by worker one by one then the output is sent back to the webserver again.


![Elastic Beanstalk Worker Environment](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/images/aeb-architecture_worker.png "Elastic Beanstalk Worker Environment")

---

## `What is EB cli ?`

> EB cli ( ElasticBeanstalk cli) is the command which helps in accessing the Elastic Beanstalk environments and deploying any application with the help of `eb` command. We can easily download [eb](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3-install-advanced.html) command and can create and manage Elastic Beanstalk Applications.

we can learn more about `EB CLI` by clicking this [link](https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/eb-cli3.html) .


---

# **Thank You**

I hope you find it useful. If you have any doubt in any of the step then feel free to contact me.
If you find any issue in it then let me know.

<!-- [![Build Status](https://img.icons8.com/color/452/linkedin.png)](https://www.linkedin.com/in/choudharyaakash/) -->


<table>
  <tr>
    <th><a href="https://www.linkedin.com/in/choudharyaakash/" target="_blank"><img src="https://img.icons8.com/color/452/linkedin.png" alt="linkedin" width="30"/><a/></th>
    <th><a href="mailto:choudharyaakash316@gmail.com" target="_blank"><img src="https://img.icons8.com/color/344/gmail-new.png" alt="Mail" width="30"/><a/>
</th>
  </tr>
</table>