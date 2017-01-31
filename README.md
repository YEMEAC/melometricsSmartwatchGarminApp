# melometricsSmartwatchGarminApp

This is my degree final project, its main purpose was to synthesize all the knowledge acquired during the bachelor's degree.

This project is a cross-platform system to support the athletes' workout through the estimation and tracing of their Vo2Max, what is a metric to value their maximum aerobic capacity. The project is divided in different parts:

The first part of the system is an application meant to be used in a smartwatch, more concretely the device Gargmin Epix. This application estimates the user's metrics using his or her vital signs and at the same time records the vital signs in .FIT files. The smartwatch's application have been developed using its manufacturer's SDK. 

The second part of the system is a web application that allows the users to have their own account and import the information captured in the .FIT files during the estimations with the smartwatch's application. This way they can have a tracing of their metrics' evolution. To import the .FIT files the web uses a  Python's module  to decode them. The web application was developed using ASP.NET MVC Framework with C# and Bootstrap. To persist and retrieve the information a MongoDB database was integrated. Since .FIT files content thousands of registers for a single estimation so  database system with high scalability and performance in reads and write was need it. 


It was a very challenging project and rewarding, starting from an initial ideal that evolved to a greater system taking advantage of what were limitations in first instance.
