# Plantilla de Registro Masivo - VDV Panel

## Descripción
Esta plantilla permite importar múltiples usuarios a la vez en el sistema VDV Panel.

## Formato de la Plantilla

La plantilla debe ser un archivo CSV (valores separados por comas) o Excel (.xlsx) con las siguientes columnas:

### Columnas Requeridas:

1. **email** - Correo electrónico de la cuenta madre (siempre en minúsculas)
   - Ejemplo: `cliente@example.com`

2. **nombre** - Nombre del usuario o ubicación
   - Ejemplo: `Casa Principal` o `Juan Pérez`

3. **plan** - Plan del servicio
   - Valores permitidos: `Ilimitado` o `50gb`

4. **pais** - País del usuario
   - Ejemplo: `Venezuela`, `Colombia`, `México`

5. **dia_inicio_pago** - Día de inicio del período de pago (1-31)
   - Ejemplo: `1`

6. **dia_fin_pago** - Día de fin del período de pago (1-31)
   - Ejemplo: `5`

7. **fecha_contratacion** - Fecha en que se contrató el servicio
   - Formato: `YYYY-MM-DD` (Año-Mes-Día)
   - Ejemplo: `2025-05-15`

### Columnas Opcionales:

8. **telefono** - Número de teléfono del usuario
   - Ejemplo: `+58412345678`
   - Si no aplica, dejar vacío

9. **serial_antena** - Serial de la antena Starlink
   - Ejemplo: `KIT123456789`
   - Si no aplica, dejar vacío

## Ejemplo de Plantilla CSV

```csv
email,nombre,plan,pais,dia_inicio_pago,dia_fin_pago,fecha_contratacion,telefono,serial_antena
cliente1@example.com,Casa Principal,Ilimitado,Venezuela,1,5,2025-01-15,+58412345678,KIT123456789
cliente1@example.com,Casa Playa,50gb,Venezuela,1,5,2025-02-01,+58424567890,KIT987654321
cliente2@example.com,Oficina Central,Ilimitado,Colombia,10,15,2024-12-01,+57312345678,
cliente3@example.com,Apartamento,50gb,México,5,10,2025-03-01,,KIT555666777
```

## Ejemplo de Plantilla Excel

| email | nombre | plan | pais | dia_inicio_pago | dia_fin_pago | fecha_contratacion | telefono | serial_antena |
|-------|--------|------|------|-----------------|--------------|-------------------|----------|---------------|
| cliente1@example.com | Casa Principal | Ilimitado | Venezuela | 1 | 5 | 2025-01-15 | +58412345678 | KIT123456789 |
| cliente1@example.com | Casa Playa | 50gb | Venezuela | 1 | 5 | 2025-02-01 | +58424567890 | KIT987654321 |
| cliente2@example.com | Oficina Central | Ilimitado | Colombia | 10 | 15 | 2024-12-01 | +57312345678 | |
| cliente3@example.com | Apartamento | 50gb | México | 5 | 10 | 2025-03-01 | | KIT555666777 |

## Notas Importantes

1. **Correos en minúsculas**: Todos los correos electrónicos se convertirán automáticamente a minúsculas.

2. **Múltiples usuarios por email**: Puedes agregar varios usuarios al mismo correo electrónico (cuenta madre) simplemente repitiendo el email en diferentes filas.

3. **Pagos automáticos**: El sistema marcará automáticamente como "pagados" todos los meses desde la `fecha_contratacion` hasta el mes actual.

4. **Validación de fechas**: Asegúrate de que las fechas estén en formato `YYYY-MM-DD`.

5. **Días de pago**: El `dia_inicio_pago` debe ser menor o igual al `dia_fin_pago`.

6. **Campos opcionales**: Si no tienes información para `telefono` o `serial_antena`, simplemente deja esas celdas vacías.

## Cómo Usar la Plantilla

1. **Descargar**: Haz clic en "Descargar Plantilla" en el sistema para obtener una plantilla vacía.

2. **Llenar**: Completa la plantilla con la información de tus usuarios siguiendo el formato descrito.

3. **Guardar**: Guarda el archivo como CSV o Excel.

4. **Importar**: Haz clic en "Importar Plantilla" y selecciona tu archivo completado.

5. **Verificar**: El sistema validará los datos y te mostrará un resumen antes de importar.

## Errores Comunes

- ❌ **Email con mayúsculas**: Usar `Cliente@Example.com` en lugar de `cliente@example.com`
- ❌ **Formato de fecha incorrecto**: Usar `15/01/2025` en lugar de `2025-01-15`
- ❌ **Plan inválido**: Usar `Unlimited` en lugar de `Ilimitado` o `50gb`
- ❌ **Días fuera de rango**: Usar `32` como día de pago
- ❌ **Día inicio mayor que día fin**: Tener `dia_inicio_pago=10` y `dia_fin_pago=5`

## Soporte

Si tienes problemas con la importación, verifica que:
- El archivo esté en formato CSV o Excel (.xlsx)
- Todas las columnas requeridas estén presentes
- Los datos cumplan con los formatos especificados
- No haya filas vacías entre los datos
