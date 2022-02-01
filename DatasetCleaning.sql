-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------Data Cleaning Project-------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

SELECT *
FROM DataCleaningProject..NashvilleHousing

--Standardizing the date format----------------------------------------------------------------------------------------

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM DataCleaningProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, SaleDate)


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate)


SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM DataCleaningProject..NashvilleHousing


--Property Address Data---------------------------------------------------------


SELECT PropertyAddress
FROM DataCleaningProject..NashvilleHousing
WHERE PropertyAddress is NULL

SELECT *
FROM DataCleaningProject..NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject..NashvilleHousing AS a
JOIN DataCleaningProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaningProject..NashvilleHousing AS a
JOIN DataCleaningProject..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is NULL


----------------------------------------------------------------------------------------------------------------------------------------------------
--Splitting Address into two parts, in nature to eliminate the comma delimeter between property adress and the city in which it is located----------
----------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------Using Subsitring------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------

SELECT PropertyAddress
FROM DataCleaningProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
FROM DataCleaningProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

FROM DataCleaningProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing



----------------------------------------------------------------------------------------------------------------------------------------------------
--Splitting Address into two parts, in nature to eliminate the comma delimeter between owner address and the city in which it is located----------
----------------------------------------------------------------------------------------------------------------------------------------------------


SELECT OwnerAddress
FROM DataCleaningProject..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM DataCleaningProject..NashvilleHousing


ALTER TABLE DataCleaningProject..NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255);


UPDATE DataCleaningProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE DataCleaningProject..NashvilleHousing
ADD OwnerSplitCity VARCHAR(255);


UPDATE DataCleaningProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE DataCleaningProject..NashvilleHousing
ADD OwnerSplitState VARCHAR(255);


UPDATE DataCleaningProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM DataCleaningProject..NashvilleHousing


--Sold as vacant has a lack of order in boolean. this is soliving the Y & N values to make them Yes and No values instead

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaningProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


--Changing all N and Y to No and Yes

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END 
FROM DataCleaningProject..NashvilleHousing

--Updating dataset to include new values


UPDATE DataCleaningProject..NashvilleHousing
SET SoldAsVacant = 

CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END 
FROM DataCleaningProject..NashvilleHousing


--Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID
	) AS rownum

FROM DataCleaningProject..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE rownum > 1
ORDER BY PropertyAddress



--Removing Blanks

SELECT *
FROM DataCleaningProject..NashvilleHousing

ALTER TABLE DataCleaningProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE DataCleaningProject..NashvilleHousing
DROP COLUMN SaleDate