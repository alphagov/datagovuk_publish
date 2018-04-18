class Licence
  LicenceInfo = Struct.new(:title, :url)

  LICENCES = {
    "cc-by" => LicenceInfo.new("Creative Commons Attribution", "http://www.opendefinition.org/licenses/cc-by"),
    "cc-by-sa" => LicenceInfo.new("Creative Commons Attribution Share-Alike", "http://www.opendefinition.org/licenses/cc-by-sa"),
    "cc-nc" => LicenceInfo.new("Creative Commons Non-Commercial (Any)", "http://creativecommons.org/licenses/by-nc/2.0/"),
    "cc-zero" => LicenceInfo.new("Creative Commons CCZero", "http://www.opendefinition.org/licenses/cc-zero"),
    "notspecified" => LicenceInfo.new("License Not Specified"),
    "odc-by" => LicenceInfo.new("Open Data Commons Attribution License", "http://www.opendefinition.org/licenses/odc-by"),
    "odc-odbl" => LicenceInfo.new("Open Data Commons Open Database License (ODbL)", "http://www.opendefinition.org/licenses/odc-odbl"),
    "odc-pddl" => LicenceInfo.new("Open Data Commons Public Domain Dedication and License (PDDL)", "http://www.opendefinition.org/licenses/odc-pddl"),
    "other-closed" => LicenceInfo.new("Other (Not Open)"),
    "other-nc" => LicenceInfo.new("Other (Non-Commercial)"),
    "other-open" => LicenceInfo.new("Other (Open)"),
    "other-pd" => LicenceInfo.new("Other (Public Domain)"),
    "uk-ogl" => LicenceInfo.new("Open Government Licence", "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/"),
  }

  def self.lookup(licence_code)
    LICENCES.fetch(licence_code, LicenceInfo.new)
  end
end