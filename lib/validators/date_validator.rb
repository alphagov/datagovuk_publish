class DateValidator < ActiveModel::Validator
  def validate(record)
    return if record.documentation

    if record.dataset.weekly?
      ok_start_day = validate_start_day(record)
      ok_start_month = validate_start_month(record)
      ok_start_year = validate_start_year(record)
      ok_end_day = validate_end_day(record)
      ok_end_month = validate_end_year(record)
      ok_end_year = validate_end_month(record)

      if (ok_start_day && ok_start_month && ok_start_year)
        validate_start_date(record)
      end

      if (ok_end_day && ok_end_month && ok_end_year)
        validate_end_date(record)
      end
    elsif record.dataset.monthly?
      validate_start_month(record)
      validate_start_year(record)
    elsif record.dataset.financial_yearly? || record.dataset.annually?
      validate_start_year(record)
    elsif record.dataset.quarterly?
      validate_start_year(record)
    end
  end


  private
  def validate_start_date(record)
    if record.dataset.monthly? || record.dataset.weekly?
      begin
        Date.new(record.start_year.to_i, record.start_month.to_i, (record.start_day || 1).to_i)
      rescue ArgumentError
        record.errors[:start_date] << (record.dataset.weekly? ? "Please enter a valid start date" : "Please enter a valid date")
      end
    end
  end

  def validate_end_date(record)
    if record.dataset.weekly?
      begin
        Date.new(record.end_year.to_i, record.end_month.to_i, record.end_day.to_i)
      rescue ArgumentError
        record.errors[:end_date] << "Please enter a valid end date"
      end
    end
  end

  def validate_start_year(record)
    start_year = record.start_year.to_i
    if record.start_year && (start_year < 1000 || start_year > 5000)
      record.errors[:start_year] << (record.dataset.weekly? ? "Please enter a valid start year" : "Please enter a valid year")
      return false
    end
    return true
  end
  def validate_end_year(record)
    end_year = record.end_year.to_i
    if record.end_year && (end_year < 1000 || end_year > 5000)
      record.errors[:end_year] << "Please enter a valid end year"
      return false
    end
    return true
  end
  def validate_start_month(record)
    start_month = record.start_month.to_i
    if record.start_month && (start_month < 1 || start_month > 12)
      record.errors[:start_month] << (record.dataset.weekly? ? "Please enter a valid start month" : "Please enter a valid month")
      return false
    end
    return true
  end
  def validate_end_month(record)
    end_month = record.end_month.to_i
    if record.end_month && (end_month < 1 || end_month > 12)
      record.errors[:end_month] << "Please enter a valid end month"
      return false
    end
    return true
  end
  def validate_start_day(record)
    start_day = record.start_day.to_i
    if record.start_day && (start_day < 1 || start_day > 31)
      record.errors[:start_day] << (record.dataset.weekly? ? "Please enter a valid start day" : "Please enter a valid day")
      return false
    end
    return true
  end
  def validate_end_day(record)
    end_day = record.end_day.to_i
    if record.end_day && (end_day < 1 || end_day > 31)
      record.errors[:end_day] << "Please enter a valid end day"
      return false
    end
    return true
  end
end
