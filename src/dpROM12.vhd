------------------------------------------------------------------
--  File        : dpROM12.vhd
--  Description : Synchronous dual-port rom
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpROM12 is
  port (
    I_CLK    : in std_logic;
    I_ADDR_A : in std_logic_vector(9 downto 0);
    I_ADDR_B : in std_logic_vector(9 downto 0);
    O_DATA_A : out std_logic_vector(15 downto 0);
    O_DATA_B : out std_logic_vector(15 downto 0)
  );
end entity dpROM12;

architecture arch_dpROM of dpROM12 is

  type romType is array(0 to (2**I_ADDR_A'length)-1) of std_logic_vector((O_DATA_A'length -1) downto 0);

  -- 882 samples in rom
  signal rom : romType := (
  x"0000",x"0032",x"0065",x"0097",x"00C9",x"00FB",x"012E",x"0160",x"0192",x"01C4",x"01F7",x"0229",x"025B",x"028D",x"02C0",x"02F2",
  x"0324",x"0356",x"0389",x"03BB",x"03ED",x"041F",x"0452",x"0484",x"04B6",x"04E8",x"051B",x"054D",x"057F",x"05B1",x"05E3",x"0616",
  x"0648",x"067A",x"06AC",x"06DE",x"0711",x"0743",x"0775",x"07A7",x"07D9",x"080B",x"083E",x"0870",x"08A2",x"08D4",x"0906",x"0938",
  x"096A",x"099D",x"09CF",x"0A01",x"0A33",x"0A65",x"0A97",x"0AC9",x"0AFB",x"0B2D",x"0B5F",x"0B92",x"0BC4",x"0BF6",x"0C28",x"0C5A",
  x"0C8C",x"0CBE",x"0CF0",x"0D22",x"0D54",x"0D86",x"0DB8",x"0DEA",x"0E1C",x"0E4E",x"0E80",x"0EB1",x"0EE3",x"0F15",x"0F47",x"0F79",
  x"0FAB",x"0FDD",x"100F",x"1041",x"1072",x"10A4",x"10D6",x"1108",x"113A",x"116C",x"119D",x"11CF",x"1201",x"1233",x"1264",x"1296",
  x"12C8",x"12FA",x"132B",x"135D",x"138F",x"13C0",x"13F2",x"1424",x"1455",x"1487",x"14B9",x"14EA",x"151C",x"154D",x"157F",x"15B0",
  x"15E2",x"1613",x"1645",x"1676",x"16A8",x"16D9",x"170B",x"173C",x"176E",x"179F",x"17D0",x"1802",x"1833",x"1865",x"1896",x"18C7",
  x"18F9",x"192A",x"195B",x"198C",x"19BE",x"19EF",x"1A20",x"1A51",x"1A82",x"1AB4",x"1AE5",x"1B16",x"1B47",x"1B78",x"1BA9",x"1BDA",
  x"1C0B",x"1C3C",x"1C6D",x"1C9E",x"1CCF",x"1D00",x"1D31",x"1D62",x"1D93",x"1DC4",x"1DF5",x"1E26",x"1E57",x"1E87",x"1EB8",x"1EE9",
  x"1F1A",x"1F4A",x"1F7B",x"1FAC",x"1FDD",x"200D",x"203E",x"206F",x"209F",x"20D0",x"2100",x"2131",x"2161",x"2192",x"21C2",x"21F3",
  x"2223",x"2254",x"2284",x"22B5",x"22E5",x"2315",x"2346",x"2376",x"23A6",x"23D7",x"2407",x"2437",x"2467",x"2497",x"24C8",x"24F8",
  x"2528",x"2558",x"2588",x"25B8",x"25E8",x"2618",x"2648",x"2678",x"26A8",x"26D8",x"2708",x"2737",x"2767",x"2797",x"27C7",x"27F7",
  x"2826",x"2856",x"2886",x"28B5",x"28E5",x"2915",x"2944",x"2974",x"29A3",x"29D3",x"2A02",x"2A32",x"2A61",x"2A91",x"2AC0",x"2AF0",
  x"2B1F",x"2B4E",x"2B7D",x"2BAD",x"2BDC",x"2C0B",x"2C3A",x"2C6A",x"2C99",x"2CC8",x"2CF7",x"2D26",x"2D55",x"2D84",x"2DB3",x"2DE2",
  x"2E11",x"2E40",x"2E6E",x"2E9D",x"2ECC",x"2EFB",x"2F2A",x"2F58",x"2F87",x"2FB6",x"2FE4",x"3013",x"3041",x"3070",x"309E",x"30CD",
  x"30FB",x"312A",x"3158",x"3187",x"31B5",x"31E3",x"3211",x"3240",x"326E",x"329C",x"32CA",x"32F8",x"3326",x"3355",x"3383",x"33B1",
  x"33DF",x"340C",x"343A",x"3468",x"3496",x"34C4",x"34F2",x"351F",x"354D",x"357B",x"35A8",x"35D6",x"3604",x"3631",x"365F",x"368C",
  x"36BA",x"36E7",x"3715",x"3742",x"376F",x"379C",x"37CA",x"37F7",x"3824",x"3851",x"387E",x"38AB",x"38D9",x"3906",x"3933",x"3960",
  x"398C",x"39B9",x"39E6",x"3A13",x"3A40",x"3A6C",x"3A99",x"3AC6",x"3AF2",x"3B1F",x"3B4C",x"3B78",x"3BA5",x"3BD1",x"3BFE",x"3C2A",
  x"3C56",x"3C83",x"3CAF",x"3CDB",x"3D07",x"3D33",x"3D60",x"3D8C",x"3DB8",x"3DE4",x"3E10",x"3E3C",x"3E68",x"3E93",x"3EBF",x"3EEB",
  x"3F17",x"3F43",x"3F6E",x"3F9A",x"3FC5",x"3FF1",x"401D",x"4048",x"4073",x"409F",x"40CA",x"40F6",x"4121",x"414C",x"4177",x"41A2",
  x"41CE",x"41F9",x"4224",x"424F",x"427A",x"42A5",x"42D0",x"42FA",x"4325",x"4350",x"437B",x"43A5",x"43D0",x"43FB",x"4425",x"4450",
  x"447A",x"44A5",x"44CF",x"44F9",x"4524",x"454E",x"4578",x"45A3",x"45CD",x"45F7",x"4621",x"464B",x"4675",x"469F",x"46C9",x"46F3",
  x"471C",x"4746",x"4770",x"479A",x"47C3",x"47ED",x"4816",x"4840",x"4869",x"4893",x"48BC",x"48E5",x"490F",x"4938",x"4961",x"498A",
  x"49B4",x"49DD",x"4A06",x"4A2F",x"4A58",x"4A80",x"4AA9",x"4AD2",x"4AFB",x"4B24",x"4B4C",x"4B75",x"4B9D",x"4BC6",x"4BEE",x"4C17",
  x"4C3F",x"4C68",x"4C90",x"4CB8",x"4CE0",x"4D09",x"4D31",x"4D59",x"4D81",x"4DA9",x"4DD1",x"4DF9",x"4E20",x"4E48",x"4E70",x"4E98",
  x"4EBF",x"4EE7",x"4F0E",x"4F36",x"4F5D",x"4F85",x"4FAC",x"4FD4",x"4FFB",x"5022",x"5049",x"5070",x"5097",x"50BE",x"50E5",x"510C",
  x"5133",x"515A",x"5181",x"51A8",x"51CE",x"51F5",x"521B",x"5242",x"5268",x"528F",x"52B5",x"52DC",x"5302",x"5328",x"534E",x"5374",
  x"539B",x"53C1",x"53E7",x"540C",x"5432",x"5458",x"547E",x"54A4",x"54C9",x"54EF",x"5515",x"553A",x"5560",x"5585",x"55AA",x"55D0",
  x"55F5",x"561A",x"563F",x"5664",x"568A",x"56AF",x"56D3",x"56F8",x"571D",x"5742",x"5767",x"578B",x"57B0",x"57D5",x"57F9",x"581E",
  x"5842",x"5867",x"588B",x"58AF",x"58D3",x"58F8",x"591C",x"5940",x"5964",x"5988",x"59AC",x"59CF",x"59F3",x"5A17",x"5A3B",x"5A5E",
  x"5A82",x"5AA5",x"5AC9",x"5AEC",x"5B0F",x"5B33",x"5B56",x"5B79",x"5B9C",x"5BBF",x"5BE2",x"5C05",x"5C28",x"5C4B",x"5C6E",x"5C91",
  x"5CB3",x"5CD6",x"5CF9",x"5D1B",x"5D3E",x"5D60",x"5D82",x"5DA5",x"5DC7",x"5DE9",x"5E0B",x"5E2D",x"5E4F",x"5E71",x"5E93",x"5EB5",
  x"5ED7",x"5EF8",x"5F1A",x"5F3C",x"5F5D",x"5F7F",x"5FA0",x"5FC2",x"5FE3",x"6004",x"6025",x"6047",x"6068",x"6089",x"60AA",x"60CB",
  x"60EB",x"610C",x"612D",x"614E",x"616E",x"618F",x"61AF",x"61D0",x"61F0",x"6211",x"6231",x"6251",x"6271",x"6291",x"62B1",x"62D1",
  x"62F1",x"6311",x"6331",x"6351",x"6370",x"6390",x"63AF",x"63CF",x"63EE",x"640E",x"642D",x"644C",x"646C",x"648B",x"64AA",x"64C9",
  x"64E8",x"6507",x"6525",x"6544",x"6563",x"6582",x"65A0",x"65BF",x"65DD",x"65FC",x"661A",x"6638",x"6656",x"6675",x"6693",x"66B1",
  x"66CF",x"66ED",x"670A",x"6728",x"6746",x"6764",x"6781",x"679F",x"67BC",x"67DA",x"67F7",x"6814",x"6832",x"684F",x"686C",x"6889",
  x"68A6",x"68C3",x"68E0",x"68FC",x"6919",x"6936",x"6952",x"696F",x"698B",x"69A8",x"69C4",x"69E0",x"69FD",x"6A19",x"6A35",x"6A51",
  x"6A6D",x"6A89",x"6AA4",x"6AC0",x"6ADC",x"6AF8",x"6B13",x"6B2F",x"6B4A",x"6B65",x"6B81",x"6B9C",x"6BB7",x"6BD2",x"6BED",x"6C08",
  x"6C23",x"6C3E",x"6C59",x"6C74",x"6C8E",x"6CA9",x"6CC3",x"6CDE",x"6CF8",x"6D13",x"6D2D",x"6D47",x"6D61",x"6D7B",x"6D95",x"6DAF",
  x"6DC9",x"6DE3",x"6DFD",x"6E16",x"6E30",x"6E4A",x"6E63",x"6E7C",x"6E96",x"6EAF",x"6EC8",x"6EE1",x"6EFB",x"6F14",x"6F2C",x"6F45",
  x"6F5E",x"6F77",x"6F90",x"6FA8",x"6FC1",x"6FD9",x"6FF2",x"700A",x"7022",x"703A",x"7053",x"706B",x"7083",x"709B",x"70B2",x"70CA",
  x"70E2",x"70FA",x"7111",x"7129",x"7140",x"7158",x"716F",x"7186",x"719D",x"71B4",x"71CB",x"71E2",x"71F9",x"7210",x"7227",x"723E",
  x"7254",x"726B",x"7281",x"7298",x"72AE",x"72C4",x"72DB",x"72F1",x"7307",x"731D",x"7333",x"7349",x"735E",x"7374",x"738A",x"739F",
  x"73B5",x"73CA",x"73E0",x"73F5",x"740A",x"7420",x"7435",x"744A",x"745F",x"7474",x"7488",x"749D",x"74B2",x"74C6",x"74DB",x"74F0",
  x"7504",x"7518",x"752D",x"7541",x"7555",x"7569",x"757D",x"7591",x"75A5",x"75B8",x"75CC",x"75E0",x"75F3",x"7607",x"761A",x"762D",
  x"7641",x"7654",x"7667",x"767A",x"768D",x"76A0",x"76B3",x"76C6",x"76D8",x"76EB",x"76FE",x"7710",x"7722",x"7735",x"7747",x"7759",
  x"776B",x"777D",x"778F",x"77A1",x"77B3",x"77C5",x"77D7",x"77E8",x"77FA",x"780B",x"781D",x"782E",x"783F",x"7850",x"7862",x"7873",
  x"7884",x"7894",x"78A5",x"78B6",x"78C7",x"78D7",x"78E8",x"78F8",x"7909",x"7919",x"7929",x"7939",x"794A",x"795A",x"796A",x"7979",
  x"7989",x"7999",x"79A9",x"79B8",x"79C8",x"79D7",x"79E6",x"79F6",x"7A05",x"7A14",x"7A23",x"7A32",x"7A41",x"7A50",x"7A5F",x"7A6D",
  x"7A7C",x"7A8B",x"7A99",x"7AA8",x"7AB6",x"7AC4",x"7AD2",x"7AE0",x"7AEE",x"7AFC",x"7B0A",x"7B18",x"7B26",x"7B33",x"7B41",x"7B4F",
  x"7B5C",x"7B69",x"7B77",x"7B84",x"7B91",x"7B9E",x"7BAB",x"7BB8",x"7BC5",x"7BD2",x"7BDE",x"7BEB",x"7BF8",x"7C04",x"7C10",x"7C1D",
  x"7C29",x"7C35",x"7C41",x"7C4D",x"7C59",x"7C65",x"7C71",x"7C7D",x"7C88",x"7C94",x"7C9F",x"7CAB",x"7CB6",x"7CC1",x"7CCD",x"7CD8",
  x"7CE3",x"7CEE",x"7CF9",x"7D04",x"7D0E",x"7D19",x"7D24",x"7D2E",x"7D39",x"7D43",x"7D4D",x"7D57",x"7D62",x"7D6C",x"7D76",x"7D80",
  x"7D89",x"7D93",x"7D9D",x"7DA6",x"7DB0",x"7DB9",x"7DC3",x"7DCC",x"7DD5",x"7DDF",x"7DE8",x"7DF1",x"7DFA",x"7E02",x"7E0B",x"7E14",
  x"7E1D",x"7E25",x"7E2E",x"7E36",x"7E3E",x"7E47",x"7E4F",x"7E57",x"7E5F",x"7E67",x"7E6F",x"7E77",x"7E7E",x"7E86",x"7E8D",x"7E95",
  x"7E9C",x"7EA4",x"7EAB",x"7EB2",x"7EB9",x"7EC0",x"7EC7",x"7ECE",x"7ED5",x"7EDC",x"7EE2",x"7EE9",x"7EEF",x"7EF6",x"7EFC",x"7F02",
  x"7F09",x"7F0F",x"7F15",x"7F1B",x"7F21",x"7F26",x"7F2C",x"7F32",x"7F37",x"7F3D",x"7F42",x"7F48",x"7F4D",x"7F52",x"7F57",x"7F5C",
  x"7F61",x"7F66",x"7F6B",x"7F70",x"7F74",x"7F79",x"7F7D",x"7F82",x"7F86",x"7F8A",x"7F8F",x"7F93",x"7F97",x"7F9B",x"7F9F",x"7FA2",
  x"7FA6",x"7FAA",x"7FAD",x"7FB1",x"7FB4",x"7FB8",x"7FBB",x"7FBE",x"7FC1",x"7FC4",x"7FC7",x"7FCA",x"7FCD",x"7FD0",x"7FD2",x"7FD5",
  x"7FD8",x"7FDA",x"7FDC",x"7FDF",x"7FE1",x"7FE3",x"7FE5",x"7FE7",x"7FE9",x"7FEB",x"7FEC",x"7FEE",x"7FF0",x"7FF1",x"7FF3",x"7FF4",
  x"7FF5",x"7FF6",x"7FF7",x"7FF8",x"7FF9",x"7FFA",x"7FFB",x"7FFC",x"7FFD",x"7FFD",x"7FFE",x"7FFE",x"7FFE",x"7FFF",x"7FFF",x"7FFF" );

  begin

    -- @Task: Propogate a word to the PORT_A
    process (I_CLK) is
    begin
      if (rising_edge(I_CLK)) then
        O_DATA_A <= rom(to_integer(unsigned(I_ADDR_A)));
      end if;
    end process;

    -- @Task: Propogate a word to the PORT_B
    process (I_CLK) is
    begin
      if (rising_edge(I_CLK)) then
        O_DATA_B <= rom(to_integer(unsigned(I_ADDR_B)));
      end if;
    end process;

end architecture arch_dpROM;
------------------------------------------------------------------
--  End of File: dpROM12.vhd
------------------------------------------------------------------




