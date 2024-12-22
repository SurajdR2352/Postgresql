CREATE OR REPLACE FUNCTION validate_temperature_data(
    measurement_value NUMERIC,
    sensor_name TEXT DEFAULT 'temperature_sensor',
    handling_strategy TEXT DEFAULT 'clamp'
)
RETURNS TABLE (
    validated_value NUMERIC,
    is_valid BOOLEAN,
    error_message TEXT
) AS $$
DECLARE
    min_limit CONSTANT NUMERIC := -50; -- set min value 
    max_limit CONSTANT NUMERIC := 150; -- set max value as per your machine understanding
BEGIN
    IF measurement_value IS NULL THEN
        RETURN QUERY SELECT 
            NULL::NUMERIC,
            FALSE,
            format('Null value received from temperature sensor: %s', sensor_name);
        RETURN;
    END IF;

    IF measurement_value >= min_limit AND measurement_value <= max_limit THEN
        RETURN QUERY SELECT
            measurement_value,
            TRUE,
            NULL::TEXT;
        RETURN;
    END IF;

    CASE handling_strategy
        WHEN 'clamp' THEN
            RETURN QUERY SELECT
                LEAST(MAX(max_limit), GREATEST(measurement_value, min_limit)),
                FALSE,
                format('Temperature %s°C from sensor %s was clamped to range [%s, %s]',
                       measurement_value::TEXT, sensor_name, min_limit::TEXT, max_limit::TEXT);

        WHEN 'null' THEN
            RETURN QUERY SELECT
                NULL::NUMERIC,
                FALSE,
                format('Temperature %s°C from sensor %s was outside valid range [%s, %s]',
                       measurement_value::TEXT, sensor_name, min_limit::TEXT, max_limit::TEXT);

        WHEN 'error' THEN
            RETURN QUERY SELECT
                measurement_value,
                FALSE,
                format('Error: Temperature %s°C from sensor %s exceeded valid range [%s, %s]',
                       measurement_value::TEXT, sensor_name, min_limit::TEXT, max_limit::TEXT);

        ELSE
            RETURN QUERY SELECT
                NULL::NUMERIC,
                FALSE,
                format('Unknown handling strategy: %s', handling_strategy);
    END CASE;
END;
$$ LANGUAGE plpgsql;
