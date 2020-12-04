using System;
using System.Linq;
using System.Collections.Generic;
using System.Text.RegularExpressions;


IEnumerable<string> LoadData(string file){
    var text = System.IO.File.ReadAllText(file);
    return
        from passport in text.Split("\n\n")
        select passport.Replace('\n', ' ');
}

IDictionary<string, string> TransformToPassport(string passport){
    return new Dictionary<string, string>(
        passport
            .Split(' ', StringSplitOptions.RemoveEmptyEntries)
            .Select(e => e.Split(':'))
            .Select(e => KeyValuePair.Create(e[0], e[1]))
    );
}

var necessaryFields = new HashSet<string>(){
    "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"
};
bool PassportHasValidFields(IDictionary<string, string> passport){
    return necessaryFields.IsSubsetOf(passport.Keys);
}

bool ValueInRange(string value, int min, int max){
    int integerValue;
    return (int.TryParse(value, out integerValue)) && (min <= integerValue) && (integerValue <= max);
}

bool PassportHasValidBirthYear(IDictionary<string, string> passport){
    return ValueInRange(passport["byr"], 1920, 2002);
}

bool PassportHasValidIssueYear(IDictionary<string, string> passport){
    return ValueInRange(passport["iyr"], 2010, 2020);
}

bool PassportHasValidExpirationYear(IDictionary<string, string> passport){
    return ValueInRange(passport["eyr"], 2020, 2030);
}

bool PassportHasValidHeight(IDictionary<string, string> passport){
    var heigth = passport["hgt"];

    var unitIndex = heigth.Length - 2;
    var unit = heigth.Substring(unitIndex);
    var numericHeight = heigth.Substring(0, unitIndex);

    int min, max;
    switch(unit){
        case "cm":
            (min, max) = (150, 193);
            break;
        case "in":
            (min, max) = (59, 76);
            break;
        default:
            return false;
    }

    return ValueInRange(numericHeight, min, max);
}

var hairColorRegex = new Regex(@"^#[0-9a-f]{6}$");
bool PassportHasValidHairColor(IDictionary<string, string> passport){
    return hairColorRegex.IsMatch(passport["hcl"]);
}

var validEyeColors = new HashSet<string>(){
    "amb", "blu", "brn", "gry", "grn", "hzl", "oth"
};
bool PassportHasValidEyeColor(IDictionary<string, string> passport){
    return validEyeColors.Contains(passport["ecl"]);
}

var passwordIdRegex = new Regex(@"^\d{9}$");
bool PassportHasValidPasswordId(IDictionary<string, string> passport){
    return passwordIdRegex.IsMatch(passport["pid"]);
}

var count = LoadData(@"input.txt")
    .AsParallel()
    .Select(TransformToPassport)
    .Where(PassportHasValidFields)
    .Where(PassportHasValidBirthYear)
    .Where(PassportHasValidIssueYear)
    .Where(PassportHasValidExpirationYear)
    .Where(PassportHasValidHeight)
    .Where(PassportHasValidHairColor)
    .Where(PassportHasValidEyeColor)
    .Where(PassportHasValidPasswordId)
    .Count();
Console.WriteLine(count);
