Descripción

El presente repositorio contiene la implementacion de pruebas de rendimiento con JMeter integradas en un proceso de CI/CD automatizado. El objetivo del trabajo es ejecutar pruebas de cargas sobre una API, evaluar automáticamente los resultados con umbrales predefinidos y generar reportes HTML que se publiquen como artefactos del pipeline. 

El pipeline automatiza todo el flujo de pruebas de rendimiento mediante GitHub Actions 
1. Descarga el código del repositorio+
2. Ejecuta las pruebas de JMeter dentro de un contenedor Docker.
3. Genera los resultados en formato .jlt y el reporte HTML.
4. Aplica un script de validación de umbrales que analiza el rendimiento.
5. La ejecución falla automáticamente si los resultados no cumplen con los límites establecidos.
6. Publica los artefactos (reportes) en la sesión de resultados del pipeline.  

Para realizar las pruebas se utilizó la API pública de httpbin.org, que proporciona endpoints gratuitos para pruebas de rendimmiento y validación de peticiones HTTP.
Especificamente en este caso se probó:

GET /get

POST /post

GET /delay/1

GET /status/200

GET /bytes/1024

PUT /put

GET /headers

Cada endpoint fue incluido en el plan de pruebas api-performance.jmx, simulando 50 usuarios simultáneos con un ramp-up de 2 minutos.

Para validar la cálidad del rendimientos se aplicaron los siguientes criterios: 

- P95 < 500ms 

- tasa de error < 1%

Estos valores se evalúan mediante un script (thresholds.sh) que analiza el archivo de resultados .jtl generado por JMeter. 

Cuando los resulados no cumplen con los umbrales definidos, el script marca la ejecución como fallida, probocando que el pipeline de CI/CD se detenga.
Esto actua como una puerta de control automatizada, no aceptando cambios dentro de coódigo que provocan que el rendimiento no este dentro de los umbrales.

Cómo ejecutar

El pipeline se ejecuta automáticamente al realizar un push o pull request.
Los resultados pueden ser visualizados desde la pestaña “Actions” en el repositorio, y descargar el artefacto “jmeter-report” que contiene el dashboard HTML.

📊 Resultados esperados
l. finalizar la ejecución, se espera obtener:
- Un reporte HTML de JMeter en jmeter/report/index.html con:
- Gráficas de latencia, throughput, errores y percentiles.
- Estadísticas detalladas por endpoint.
- Resumen de los valores de P95 y error rate.

2. Salida en consola o logs mostrando el estado del pipeline:
- ✅ Si se cumplen los umbrales.
- ❌ Si alguno excede los límites establecidos.

3. Artefactos publicados automáticamente por GitHub Actions, disponibles para descarga.

4. Fallo controlado del pipeline (exit code 1) en caso de incumplimiento de umbrales, impidiendo el despliegue o aprobación de cambios.



