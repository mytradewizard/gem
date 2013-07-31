def month(from_now)
  (Date.today >> from_now).strftime('%Y%m')
end