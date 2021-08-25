defmodule Npf.Filings.Utils.Parser do
  import SweetXml

  @filing_root ~x"/Return/ReturnHeader"e
  @tax_period_begin_date ["TaxPeriodBeginDt", "TaxPeriodBeginDate"]
  @tax_period_end_date ["TaxPeriodEndDt", "TaxPeriodEndDate"]

  @filer_root ~x"/Return/ReturnHeader/Filer"e
  @recipients_list_root ~x"/Return/ReturnData/IRS990ScheduleI|/Return/ReturnData/IRS990PF/SupplementaryInformationGrp"e

  @address_line_1 [
    "USAddress/AddressLine1",
    "AddressUS/AddressLine1",
    "USAddress/AddressLine1Txt",
    "RecipientUSAddress/AddressLine1Txt"
  ]
  @address_line_2 [
    "USAddress/AddressLine2",
    "AddressUS/AddressLine2",
    "USAddress/AddressLine2Txt",
    "RecipientUSAddress/AddressLine2Txt"
  ]
  @city ["USAddress/City", "AddressUS/City", "USAddress/CityNm", "RecipientUSAddress/CityNm"]
  @ein ["EIN", "RecipientEIN", "EINOfRecipient"]
  @name_line_1 [
    "BusinessName/BusinessNameLine1",
    "Name/BusinessNameLine1",
    "BusinessName/BusinessNameLine1Txt",
    "RecipientNameBusiness/BusinessNameLine1",
    "RecipientBusinessName/BusinessNameLine1",
    "RecipientBusinessName/BusinessNameLine1Txt",
    "RecipientPersonNm"
  ]
  @name_line_2 [
    "BusinessName/BusinessNameLine2",
    "Name/BusinessNameLine2",
    "BusinessName/BusinessNameLine2Txt",
    "RecipientNameBusiness/BusinessNameLine2",
    "RecipientBusinessName/BusinessNameLine2",
    "RecipientBusinessName/BusinessNameLine2Txt"
  ]
  @state [
    "USAddress/State",
    "AddressUS/State",
    "USAddress/StateAbbreviationCd",
    "RecipientUSAddress/StateAbbreviationCd"
  ]
  @zip_code [
    "USAddress/ZIPCode",
    "AddressUS/ZIPCode",
    "USAddress/ZIPCd",
    "RecipientUSAddress/ZIPCd"
  ]

  @amount ["CashGrantAmt", "AmountOfCashGrant", "Amt"]
  @purpose ["PurposeOfGrantTxt", "PurposeOfGrant", "GrantOrContributionPurposeTxt"]

  @spec parse_filing(binary()) :: map()
  def parse_filing(document) do
    document
    |> xpath(
      @filing_root,
      tax_period_begin_date:
        generate_sigil(@tax_period_begin_date, 's') |> transform_by(&Date.from_iso8601!/1),
      tax_period_end_date:
        generate_sigil(@tax_period_end_date, 's') |> transform_by(&Date.from_iso8601!/1)
    )
  end

  @spec parse_filer(binary()) :: map()
  def parse_filer(document) do
    document
    |> xpath(
      @filer_root,
      ein: generate_sigil(@ein, 'i'),
      address_line_1: generate_sigil(@address_line_1, 's'),
      address_line_2: generate_sigil(@address_line_2, 'so'),
      city: generate_sigil(@city, 's'),
      state: generate_sigil(@state, 's'),
      zip_code: generate_sigil(@zip_code, 's'),
      name_line_1: generate_sigil(@name_line_1, 's'),
      name_line_2: generate_sigil(@name_line_2, 'so')
    )
  end

  @spec parse_receivers(binary()) :: map()
  def parse_receivers(document) do
    xmap(document,
      recipients: [
        @recipients_list_root,
        organization: [
          ~x"./RecipientTable|./GrantOrContributionPdDurYrGrp"l,
          ein: generate_sigil(@ein, 'io'),
          address_line_1: generate_sigil(@address_line_1, 's'),
          address_line_2: generate_sigil(@address_line_2, 'so'),
          city: generate_sigil(@city, 's'),
          state: generate_sigil(@state, 's'),
          zip_code: generate_sigil(@zip_code, 's'),
          name_line_1: generate_sigil(@name_line_1, 's'),
          name_line_2: generate_sigil(@name_line_2, 'so')
        ],
        award: [
          ~x"./RecipientTable|./GrantOrContributionPdDurYrGrp"l,
          amount: generate_sigil(@amount, 'io'),
          purpose: generate_sigil(@purpose, 's')
        ]
      ]
    )
  end

  @spec generate_sigil(list(String.t()), charlist()) :: SweetXml.t()
  defp generate_sigil(patterns, modifiers) do
    patterns
    |> Enum.map_join("|", fn pattern ->
      "./#{pattern}/text()"
    end)
    |> SweetXml.sigil_x(modifiers)
  end
end
