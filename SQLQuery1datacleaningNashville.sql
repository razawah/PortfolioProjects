
-- DATA CLEANING IN SQL

SELECT * 
FROM PortfolioProject..Nashville


-- Standardize Sale Date

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject..Nashville

UPDATE PortfolioProject..Nashville
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE PortfolioProject..Nashville
	Add SaledateConverted Date;

UPDATE PortfolioProject..Nashville
SET SaleDateConverted = CONVERT(date, SaleDate)

-- Populate Property Address Data

SELECT *
FROM PortfolioProject..Nashville
where PropertyAddress is not Null
Order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville a
JOIN PortfolioProject..Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..Nashville a
JOIN PortfolioProject..Nashville b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is NULL


-- Breaking the Address into individual Columns (Address, City, State) using Substring and PARSENAME



SELECT PropertyAddress
FROM PortfolioProject..Nashville
--where PropertyAddress is not Null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
	Add PropertySplitAddress nvarchar(255)

UPDATE PortfolioProject..Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..Nashville
	Add PropertySplitCity nvarchar(255)

UPDATE PortfolioProject..Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..Nashville



SELECT 
PARSENAME(Replace(OwnerAddress, ',','.'), 3),
PARSENAME(Replace(OwnerAddress, ',','.'), 2),
PARSENAME(Replace(OwnerAddress, ',','.'), 1)
From PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
	Add OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject..Nashville
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)

ALTER TABLE PortfolioProject..Nashville
	Add OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject..Nashville
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'), 2)


ALTER TABLE PortfolioProject..Nashville
	Add OwnerSplitState nvarchar(255)

UPDATE PortfolioProject..Nashville
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'), 1)

SELECT * 
from PortfolioProject..Nashville

-- Change Y and N to Yes or No in the SodAsVacant Column

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant) 
from PortfolioProject..Nashville
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
from PortfolioProject..Nashville

UPDATE PortfolioProject..Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..Nashville
Group by SoldAsVacant
Order by 2


-- Removing Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelId,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 Order By
					UniqueID
					) row_num

FROM PortfolioProject..Nashville
--Order by ParcelID
)

Select *
from RowNumCTE
where row_num > 1
--order by PropertyAddress


-- DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProject..Nashville

ALTER TABLE PortfolioProject..Nashville
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress

ALTER TABLE PortfolioProject..Nashville
DROP COLUMN SaleDate