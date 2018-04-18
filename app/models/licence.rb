require 'ostruct'

class Licence
  LicenceInfo = Struct.new(:title, :url)

  LICENCES = {
    "uk-ogl" => LicenceInfo.new("Open Government Licence", "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/"),
    "cc-nc" => LicenceInfo.new("Creative Commons Non-Commercial (Any)", "http://creativecommons.org/licenses/by-nc/2.0/"),
    "cc-zero" => LicenceInfo.new("Creative Commons CCZero", "http://www.opendefinition.org/licenses/cc-zero"),
    "cc-by-sa" => LicenceInfo.new("Creative Commons Attribution Share-Alike", "http://www.opendefinition.org/licenses/cc-by-sa"),
    "cc-by" => LicenceInfo.new("Creative Commons Attribution", "http://www.opendefinition.org/licenses/cc-by"),
    "odc-odbl" => LicenceInfo.new("Open Data Commons Open Database License (ODbL)", "http://www.opendefinition.org/licenses/odc-odbl"),
    "notspecified" => LicenceInfo.new("License Not Specified", nil),
    "other-pd" => LicenceInfo.new("Other (Public Domain)", nil),
    "other-open" => LicenceInfo.new("Other (Open)", nil),
    "other-closed" => LicenceInfo.new("Other (Not Open)", nil),
    "other-nc" => LicenceInfo.new("Other (Non-Commercial)", nil),
    "odc-pddl" => LicenceInfo.new("Open Data Commons Public Domain Dedication and License (PDDL)", "http://www.opendefinition.org/licenses/odc-pddl"),
    "odc-by" => LicenceInfo.new("Open Data Commons Attribution License", "http://www.opendefinition.org/licenses/odc-by"),
  }

  def self.lookup(licence_id)
    LICENCES.fetch(licence_id, LicenceInfo.new)
  end
end