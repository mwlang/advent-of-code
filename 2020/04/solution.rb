class Passport
  def initialize data
    @attributes = data.join(" ").split(" ").map{|attr| attr.split(":")}.to_h
  end

  def all_fields_present?
    all_fields & @attributes.keys == all_fields
  end

  # byr (Birth Year)
  # iyr (Issue Year)
  # eyr (Expiration Year)
  # hgt (Height)
  # hcl (Hair Color)
  # ecl (Eye Color)
  # pid (Passport ID)
  # cid (Country ID)
  def all_fields
    @all_fields ||= %w{byr iyr eyr hgt hcl ecl pid cid}.sort.freeze
  end

  def valid?
    all_fields_present?
  end
end

class NorthPolePassport < Passport
  def all_fields
    @all_fields ||= %w{byr iyr eyr hgt hcl ecl pid}.sort.freeze
  end
end

class NorthPoleStrictPassport < NorthPolePassport

  # byr (Birth Year) - four digits; at least 1920 and at most 2002.
  def valid_birth_year?
    @attributes["byr"].to_i.between? 1920, 2002
  end

  # iyr (Issue Year) - four digits; at least 2010 and at most 2020.
  def valid_issue_year?
    @attributes["iyr"].to_i.between? 2010, 2020
  end
  
  # eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
  def valid_expiration_year?
    @attributes["eyr"].to_i.between? 2020, 2030
  end

  # hgt (Height) - a number followed by either cm or in:
  # If cm, the number must be at least 150 and at most 193.
  # If in, the number must be at least 59 and at most 76.
  def valid_height?
    if @attributes["hgt"].nil?
      require 'pry'; binding.pry
    end
    _, ht, unit = @attributes["hgt"].match(/(\d+)(cm|in)/).to_a
    return false if ht.nil? || unit.nil?
    unit == "cm" ? ht.to_i.between?(150, 193) : ht.to_i.between?(59, 76)
  end

  # hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
  def valid_hair_color?
    @attributes["hcl"] =~ /^\#[0-9,a-f]{6}$/
  end

  # ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
  def valid_eye_color?
    %w{amb blu brn gry grn hzl oth}.include? @attributes["ecl"]
  end

  # pid (Passport ID) - a nine-digit number, including leading zeroes.
  def valid_passport?
    @attributes["pid"] =~ /^\d{9}$/
  end

  # cid (Country ID) - ignored, missing or not.

  def valid?
    all_fields_present? && [ 
      valid_birth_year?,
      valid_issue_year?,
      valid_expiration_year?,
      valid_height?,
      valid_hair_color?,
      valid_eye_color?,
      valid_passport?
    ].all?
  end
end

def load_passports passport_class
  lines = File.readlines("input.txt").map(&:chomp)

  passports = []
  data = []
  while !lines.empty?
    line = lines.shift
    if line.empty?
      passports << passport_class.new(data)
      data = []
    else
      data << line
    end
  end
  passports << passport_class.new(data) unless data.empty?
  passports
end

def valid_passports checkpoint, passport_class
  passports = load_passports passport_class
  count = passports.reduce(0){|count, p| p.valid? ? count + 1 : count}  
  puts "#{checkpoint}: #{count}"
end

valid_passports "Standard", Passport
valid_passports "North Pole", NorthPolePassport
valid_passports "North Pole Strict", NorthPoleStrictPassport
