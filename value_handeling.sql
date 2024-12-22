CREATE OR REPLACE FUNCTION validate_temperature(
    temp_value NUMERIC,
    sensor_id TEXT
)
RETURNS TABLE (
    valid_temp NUMERIC,
    is_valid BOOLEAN,
    message TEXT
) AS $$
DECLARE
    MIN_TEMP CONSTANT NUMERIC := -50;
    MAX_TEMP CONSTANT NUMERIC := 150;
BEGIN
    IF temp_value IS NULL THEN
        RETURN QUERY SELECT NULL::NUMERIC, FALSE, 
            'Sensor ' || sensor_id || ' returned NULL reading';
        RETURN;
    END IF;

    IF temp_value BETWEEN MIN_TEMP AND MAX_TEMP THEN
        RETURN QUERY SELECT temp_value, TRUE, NULL::TEXT;
        RETURN;
    END IF;

    IF temp_value < MIN_TEMP THEN
        RETURN QUERY SELECT MIN_TEMP, FALSE,
            'Sensor reading clamped to minimum: ' || MIN_TEMP || '°C';
        RETURN;
    END IF;

    RETURN QUERY SELECT MAX_TEMP, FALSE,
        'Sensor reading clamped to maximum: ' || MAX_TEMP || '°C';
END;
$$ LANGUAGE plpgsql;
