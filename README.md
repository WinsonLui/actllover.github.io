# Actuarial Theory and Practice A @ UNSW

_Social insurance program design for catastrophic climate-related displacement risk management_

---

## 1 Objectives

### 1.1 Objective of Proposed Program Design

Our team has been requested by Storslysia to design a social insurance program which provides coverage for both voluntary and involuntary displacement. The purpose of the program is to manage Storslysia’s exposure to displacement risk arising from catastrophic climate-related events, and to prevent relocation costs from exceeding 10% of its GDP each year with 90% certainty. Storslysia has confirmed that they require the program to cover the entire population, and we have incorporated benefits varying by geographic risk and socio-economic status within the program design in response to Storslysia’s diverse geography.

### 1.2 Key Metrics

The following table summarises several key metrics to be reported semi-annually to assist in monitoring the success of the proposed program across the short and long-term. 


## 2 Program Design

### 2.1 Eligibility Requirements

All citizens of Storslysia may file a claim under the proposed program given they meet the following eligibility requirements:

### 2.2 Claim Coverage

As mentioned in Section 1.1, our proposed program provides coverage for both voluntary and involuntary displacement on the basis that costs have historically been higher for involuntary relocation. The amount of coverage offered to the claimant will vary depending on factors such as property value and geographical risk, with a limit of one claimant per household affected.
Our program provides the following benefits:

#### 2.2.1 Voluntary Relocation
We have determined the primary cost associated with voluntary relocation to be accommodation search/construction. Under our proposed program, successful claimants will receive a portion of their current property value based on the percentage reduction in risk exposure from relocating from region A to region B as a lumpsum. By basing the lumpsum benefit on the reduction in risk exposure, we aim to mitigate displacement risk and incentivise citizens to relocate to safer regions.  

The value of the payout for this benefit is calculated as follows:

The subsidised amount, expressed as a percentage of current property value under the voluntary relocation scheme is outlined in table below:

#### 2.2.2 Involuntary Displacement
Our proposed program accounts for a range of payments in relation to involuntary displacement including accommodation search/construction, temporary accommodation, and the repair/replacement of household items. 

Lump-sum payments for accommodation search/construction is based on property damage under the assumption that the claimant will relocate to an accommodation of similar value. Similarly, lump-sum payments for repair/replacement of household items are set to be 57.5% of household costs based on given data.

The insurance program also provides coverage over temporary housing for up to 6 months whilst displaced claimants search for a new accommodation. These monthly benefit payments will vary based on the size of the household and geographic location and is calculated as follows:

The temporary housing cost used in the calculation above is based on the median price provided within the client’s demographic data. Further, coverage under the proposed program is limited to a fixed percentage of predicted involuntary displacement costs, which has been set to 60% to ensure displacement costs fall below 10% of GDP each year. 

### 2.3 Monitoring and Performance Evaluation

As this program is new, we will be required to continue monitoring its performance in the short and long-term and make necessary adjustments. For this report, we have defined our short and long-term timeframes as the following:
•	Short-term: 2 years
•	Long-term: 10 years

Short term monitoring should be conducted once the program has started to run so that there is sufficient data available to make relevant adjustments in the scheme for effective risk management. Lack of awareness of this newly developed social insurance program would cause delays in claims filed and insufficient data. Further, we note that the confirmation of eligibility for initial claims made will delay the full implementation of the program, particularly due to the back log of claims being processed with an inefficient system. As such, we have selected a 2-year short term period.

In contrast, long term monitoring is essential for determining the effectiveness of the proposed program and would be conducted once the scheme is fully implemented. This will allow us to ensure adequate pricing as we consider the policy's claims experience. If actual experience significantly deviates from the expected, relevant models and assumptions will need to be redesigned and updated. 

## 3 Pricing/Costs

### 3.1 Projected Costs

The simulation results for costs under program associated with voluntary relocation is as follows: 

The simulation results for costs under program associated with involuntary relocation is as follows: 

As shown in the tables above, costs associated with voluntary relocation are significantly lower and less volatile in comparison to involuntary displacement costs. 

### 3.2 Projected Costs without Program

The simulated projected cost associated with hazardous climate-related events for Storslysia’s citizens without the introduction of the program is summarised in the table below. 

We can see that projected costs are significantly lower for voluntary relocation under the proposed program, particularly in the long term as we incentivise safer relocations to reduce risk. Costs associated with involuntary displacement are partially subsidised under the program and are therefore also reduced significantly.

### 3.3 Capital Requirements

We used the 99.5th percentile of program costs cash flows under the worst-case scenario (very high emissions) to calculate the required economic capital for program to remain solvent. As outlined in the table below, we require a cash reserve of _Ꝕ 2,223,747,478.12_ for this program. 

## 4 Assumptions

### 4.1 Key Assumptions

#### 4.1.1 Involuntary Model
Simulations for projected costs for involuntary displacement were conducted under the assumption that claims frequency follows a _Poisson distribution_ and claims severity follows a _Gamma distribution_. The Poisson rate was found through the sample model provided by Storslysia, with the yearly rate interpolated under the assumption of a linear trend between decades. Weather events in the medium to major categories are assumed to occur less frequently (e.g. once a decade) and so we have adopted a 30-year average as the expected 2020 frequency in the sample model. Estimates for the Gamma scale and shape parameters were determined by fitting the data on property damages for each event category. Simulations for minor events were not found due to limitations on program coverage for damages which do not exceed 30% of property value.

When projecting costs for temporary accommodation, we have assumed a fixed period of 6 months for all claimants to account for the worst-case scenario and have based the number of people per household on the average provided in the most recent census data. The number of households affected was estimated by dividing the total property damage per hazard event by the median property value.

#### 4.1.2 Voluntary Model
