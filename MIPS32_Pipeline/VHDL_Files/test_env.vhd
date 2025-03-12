library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port( sw : in STD_LOGIC_VECTOR(7 downto 0);
          btn : in STD_LOGIC_VECTOR(4 downto 0);
          clk : in STD_LOGIC;
          cat : out STD_LOGIC_VECTOR(6 downto 0);
          an : out STD_LOGIC_VECTOR(7 downto 0);
          led : out STD_LOGIC_VECTOR (15 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC
          );
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0)
          );
end component;

component iFetch is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           branch_address : in STD_LOGIC_VECTOR(31 downto 0);
           pc_src : in STD_LOGIC;         
           jump_address : in STD_LOGIC_VECTOR(31 downto 0);
           jump : in STD_LOGIC;
           pc : out STD_LOGIC_VECTOR(31 downto 0);
           instruction : out STD_LOGIC_VECTOR(31 downto 0)
          );
end component;

component ID is
    Port(RD1 : out std_logic_vector(31 downto 0);
        RD2 : out std_logic_vector(31 downto 0);
        Ext_Imm : out std_logic_vector(31 downto 0);
        func : out std_logic_vector(5 downto 0);
        sa : out std_logic_vector(4 downto 0);
        WA : in std_logic_vector(4 downto 0);
        WD : in std_logic_vector(31 downto 0);
        Instr : in std_logic_vector(25 downto 0);
        clk :in std_logic;
        en : in std_logic;
        regWrite : in std_logic;
        ExtOp : in std_logic;
        rt : out std_logic_vector(4 downto 0);
        rd : out std_logic_vector(4 downto 0)
        );
end component;

component UC is
    Port (Instr : in STD_LOGIC_VECTOR(5 downto 0);
          RegDst : out STD_LOGIC;
          ExtOp : out STD_LOGIC;
          ALUSrc : out STD_LOGIC;
          Branch : out STD_LOGIC;
          Br_ne: out STD_LOGIC;
          Br_gtz: out STD_LOGIC;
          Jump : out STD_LOGIC;
          ALUOp : out STD_LOGIC_VECTOR(1 downto 0);
          MemWrite : out STD_LOGIC;
          MemtoReg : out STD_LOGIC;
          RegWrite : out STD_LOGIC
         );
end component;

component EX is
    Port (RD1 : in STD_LOGIC_VECTOR (31 downto 0);
          RD2 : in STD_LOGIC_VECTOR (31 downto 0);
          Ext_imm : in STD_LOGIC_VECTOR (31 downto 0);
          ALUSrc : in STD_LOGIC;
          sa : in STD_LOGIC_VECTOR (4 downto 0);
          func : in STD_LOGIC_VECTOR (5 downto 0);
          ALUOp : in STD_LOGIC_VECTOR (1 downto 0);
          PC : in STD_LOGIC_VECTOR (31 downto 0);
          RegDst: in STD_LOGIC;
          rt: in STD_LOGIC_VECTOR(4 downto 0);
          rd: in STD_LOGIC_VECTOR(4 downto 0);
          ALURes : out STD_LOGIC_VECTOR (31 downto 0);
          BranchAddress : out STD_LOGIC_VECTOR (31 downto 0);
          Zero : out STD_LOGIC;
          GTZ: out STD_LOGIC;
          rWA: out STD_LOGIC_VECTOR(4 downto 0)
          );
end component;

component MEM is
    Port ( MemWrite : in STD_LOGIC;
           ALURes : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           clk : in STD_LOGIC;
           en : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR (31 downto 0)
          );
end component;

signal en : STD_LOGIC;
signal mux : STD_LOGIC_VECTOR(31 downto 0);

--IF
signal Instruction : STD_LOGIC_VECTOR(31 downto 0);
signal PC : STD_LOGIC_VECTOR(31 downto 0);
signal JumpAddress : STD_LOGIC_VECTOR(31 downto 0);
signal PCSrc : STD_LOGIC;  

--ID
signal RD1 : STD_LOGIC_VECTOR(31 downto 0);
signal RD2 : STD_LOGIC_VECTOR(31 downto 0);
signal Ext_imm : STD_LOGIC_VECTOR(31 downto 0);
signal Func : STD_LOGIC_VECTOR(5 downto 0);
signal SA : STD_LOGIC_VECTOR(4 downto 0);
signal WD : STD_LOGIC_VECTOR(31 downto 0);
signal rt: STD_LOGIC_VECTOR(4 downto 0);
signal rd: STD_LOGIC_VECTOR(4 downto 0);

--UC
signal RegDst : STD_LOGIC;
signal ExtOp : STD_LOGIC;
signal ALUSrc : STD_LOGIC;
signal Branch : STD_LOGIC;
signal Br_ne: STD_LOGIC;
signal Br_gtz: STD_LOGIC;
signal Jump : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);
signal MemWrite : STD_LOGIC;
signal MemtoReg : STD_LOGIC;
signal RegWrite : STD_LOGIC;

--EX
signal Zero : STD_LOGIC;
signal Gtz: STD_LOGIC;
signal ALURes : STD_LOGIC_VECTOR(31 downto 0);
signal BranchAddress : STD_LOGIC_VECTOR(31 downto 0);
signal rWA: STD_LOGIC_VECTOR(4 downto 0);

--MEM
signal MemData : STD_LOGIC_VECTOR(31 downto 0);
signal ALUResOut : STD_LOGIC_VECTOR(31 downto 0);


--semnale PIPELINE

--IF_ID
signal Instruction_IF_ID : std_logic_vector(31 downto 0);
signal PC_IF_ID: std_logic_vector(31 downto 0);

--ID_EX
signal PC_ID_EX: std_logic_vector(31 downto 0);
signal RD1_ID_EX : std_logic_vector(31 downto 0);
signal RD2_ID_EX : std_logic_vector(31 downto 0);
signal Ext_imm_ID_EX : std_logic_vector(31 downto 0);
signal SA_ID_EX : std_logic_vector(4 downto 0);
signal Func_ID_EX : std_logic_vector(5 downto 0);
signal rt_ID_EX: std_logic_vector(4 downto 0);
signal rd_ID_EX: std_logic_vector(4 downto 0);
signal MemtoReg_ID_EX : std_logic;
signal RegWrite_ID_EX : std_logic;
signal MemWrite_ID_EX : std_logic;
signal Branch_ID_EX : std_logic;
signal Br_ne_ID_EX: std_logic;
signal Br_gtz_ID_EX: std_logic;
signal ALUSrc_ID_EX : std_logic;
signal ALUOp_ID_EX : std_logic_vector(1 downto 0);
signal RegDst_ID_EX : std_logic;

--EX_MEM
signal BranchAddress_EX_MEM : std_logic_vector(31 downto 0);
signal Zero_EX_MEM : std_logic;
signal Gtz_EX_MEM: std_logic;
signal ALURes_EX_MEM : std_logic_vector(31 downto 0);
signal RD2_EX_MEM : std_logic_vector(31 downto 0);
signal rd_EX_MEM: std_logic_vector(4 downto 0);
signal MemtoReg_EX_MEM : std_logic;
signal RegWrite_EX_MEM : std_logic;
signal MemWrite_EX_MEM : std_logic;
signal Branch_EX_MEM : std_logic;
signal Br_ne_EX_MEM: std_logic;
signal Br_gtz_EX_MEM: std_logic;

--MEM_WB
signal MemData_MEM_WB : std_logic_vector(31 downto 0);
signal ALURes_MEM_WB : std_logic_vector(31 downto 0);
signal rd_MEM_WB: std_logic_vector(4 downto 0);
signal MemtoReg_MEM_WB : std_logic;
signal RegWrite_MEM_WB : std_logic;

begin

    monoPulseGenerator : MPG port map (en, btn(0), clk);
    
    extragere_instructiuni : iFetch port map (clk, btn(1), en, BranchAddress_EX_MEM, PCSrc, JumpAddress, Jump, PC, Instruction);

    decodificare : ID port map (RD1, RD2, Ext_imm, Func, SA, rd_MEM_WB, WD, Instruction_IF_ID(25 downto 0), clk, en, RegWrite_MEM_WB, ExtOp, rt, rd);

    control : UC port map (Instruction_IF_ID(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Br_ne, Br_gtz, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);

    unitateDeExecutie : EX port map(RD1_ID_EX, RD2_ID_EX, Ext_imm_ID_EX, ALUSrc_ID_EX, SA_ID_EX, Func_ID_EX, ALUOp_ID_EX, PC_ID_EX, RegDst_ID_EX, rt_ID_EX, rd_ID_EX, ALURes, BranchAddress, Zero, Gtz, rWA);

    unitateDeMemorie : MEM port map(MemWrite_EX_MEM, ALURes_EX_MEM, RD2_EX_MEM, clk, en, MemData, ALUResOut);

    afisor : SSD port map (clk, mux, an, cat);
    
    --unitatea de writeBack
    with MemtoReg_MEM_WB SELECT 
        WD <= ALURes_MEM_WB when '0',
              MemData_MEM_WB when '1',
              (others => 'X') when others;
    
    
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                --IF_ID
                Instruction_IF_ID <= Instruction;
                PC_IF_ID <= PC;
                --ID_EX
                PC_ID_EX <= PC_IF_ID;
                RD1_ID_EX <= RD1;
                RD2_ID_EX <= RD2;
                Ext_imm_ID_EX <= Ext_imm;
                SA_ID_EX <= SA;
                Func_ID_EX <= Func;
                rt_ID_EX <= rt;
                rd_ID_EX <= rd;
                MemtoReg_ID_EX <= MemtoReg;
                RegWrite_ID_EX <= RegWrite;
                MemWrite_ID_EX <= MemWrite;
                Branch_ID_EX <= Branch;
                Br_ne_ID_EX <= Br_ne;
                Br_gtz_ID_EX <= Br_gtz;
                ALUSrc_ID_EX <= ALUSrc;
                ALUOp_ID_EX <= ALUOp;
                RegDst_ID_EX <= RegDst;
                --EX_MEM
                BranchAddress_EX_MEM <= BranchAddress;
                Zero_EX_MEM <= Zero;
                Gtz_EX_MEM <= Gtz;
                ALURes_EX_MEM <= ALURes;
                RD2_EX_MEM <= RD2_ID_EX;
                rd_EX_MEM <= rWA;
                MemtoReg_EX_MEM <= MemtoReg_ID_EX;
                RegWrite_EX_MEM <= RegWrite_ID_EX;
                MemWrite_EX_MEM <= MemWrite_ID_EX;
                Branch_EX_MEM <= Branch_ID_EX;
                Br_ne_EX_MEM <= Br_ne_ID_EX;
                Br_gtz_EX_MEM <= Br_gtz_ID_EX;
                --MEM_WB
                MemData_MEM_WB <= MemData;
                ALURes_MEM_WB <= ALUResOut;
                rd_MEM_WB <= rd_EX_MEM;
                MemtoReg_MEM_WB <= MemtoReg_EX_MEM;
                RegWrite_MEM_WB <= RegWrite_EX_MEM;
            end if;
        end if;
    end process;
    
    
    JumpAddress <= PC_IF_ID(31 downto 28) & Instruction_IF_ID(25 downto 0) & "00";
    PCSrc <= (Branch_EX_MEM AND Zero_EX_MEM) OR (Br_ne_EX_MEM AND NOT(Zero_EX_MEM)) OR (Br_gtz_EX_MEM AND Gtz_EX_MEM);
    
    led(11 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Br_ne & Br_gtz & Jump & MemWrite & MemtoReg & RegWrite;    
    with sw(7 downto 5) SELECT
        mux <= Instruction when "000",
               PC when "001",
               RD1_ID_EX when "010",
               RD2_ID_EX when "011",
               Ext_imm_ID_EX when "100",
               ALURes when "101",
               MemData when "110",
               WD when "111",
               (others => 'X') when others;
                   
end Behavioral;

