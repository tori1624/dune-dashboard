# Dune Dashboard : On-Chain Data Analysis

Dune Profile : [https://dune.com/dane01](https://dune.com/dane01)
<br/>

## 📌 개요
> 프로젝트별 온체인 데이터 분석을 위해 생성한 Dune 대시보드의 코드를 기록하는 저장소입니다. 해당 데이터는 블록체인 프로젝트의 토큰 발행량, DAU/MAU, 홀더 등 온체인 데이터 추이를 파악하기 위해 활용됩니다.
<br/>

## 🔍 대상 프로젝트 및 설명

1. **Pumpspace** ([Dune link](https://dune.com/dane01/pumpspace))
   - PumpSpace is the best fair launch protocol for MEME coins on the avalanche blockchain (AVAX).
     
2. **[Mizu] HyperEVM Vaults** ([Dune link](https://dune.com/dane01/mizu-hyperevm-royco))
   - The HyperEVM vaults are automated DeFi strategy vaults that provide users with a simple access point to use their assets in the Hyperliquid ecosystem.
     
3. **Aster - USDF** ([Dune link](https://dune.com/dane01/aster-usdf))
   - Aster is our unified vision to simplify and elevate the DeFi experience. $USDF is a fully collateralized stablecoin issued by Aster with custodial services provided by Ceffu.
     
4. **Redbrick** ([Dune link](https://dune.com/dane01/redbrick))
   - Redbrick is a next-generation gaming engine powered by AI, making game creation faster, easier, and more accessible to everyone.
     
5. **Glow Finance** ([Dune link](https://dune.com/dane01/glow-finance))
   - Glow Finance offers advanced DeFi solutions designed to maximize capital efficiency and optimize yield strategies.
  
<br/>

(※ 대상 프로젝트는 계속해서 추가 예정)

<br/>

## 🛠️ 기술 스택
- PostgreSQL
- Dune
<br/>

## 📁 폴더 구조
```text
dune-dashboard/
├── aster/
│ └── asusdf_stable_LP.sql
│ └── usdf.sql
│ └── usdf_stable_LP.sql
├── glow-finance/
│ └── glowSOL_holders.sql
│ └── glowSOL_holders_newOld.sql
│ └── glowSOL_supply.sql
├── hyperEVM/
│ └── hyperEVM.sql
├── pumpspace/
│ └── meme_launchpad.sql
│ └── tokens_information.sql
├── pumpspace/
│ └── daily_reward.sql
│ └── land_holders.sql
└── README.md
```

<br/>

## ⚙️ 실행 방법
```text
1. Dune 접속 및 로그인
2. 좌측 탭 중 Create > New query
3. 코드 복사, 붙여넣기 후 실행
```

<br/>
